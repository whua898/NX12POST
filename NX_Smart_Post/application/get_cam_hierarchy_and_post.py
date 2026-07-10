# NX Journal: export CAM hierarchy cache and run postprocess with the configured post.
# Run inside Siemens NX (File > Execute > Journal, or a custom toolbar button).

from __future__ import print_function

import io
import os
import traceback

import NXOpen
import NXOpen.CAM

try:
    import NXOpen.UF
except Exception:
    NXOpen_UF = None
else:
    NXOpen_UF = NXOpen.UF


# Default postprocessor name used by NXOpen.CAM.CAMSetup.Postprocess.
# Change this value when switching to another registered post, for example "my_post".
DEFAULT_POST_NAME = "smart_post"
POST_NAME = os.environ.get("NX_SMART_POST_NAME", DEFAULT_POST_NAME)
HIERARCHY_CACHE_NAME = "nx_cam_hierarchy.tcl"
LOG_NAME = "nx_smart_post_journal.log"
OUTPUT_EXT = ".nc"

try:
    text_type = unicode
except NameError:
    text_type = str

try:
    binary_type = bytes
except NameError:
    binary_type = str


def _to_text(value):
    if value is None:
        return u""
    if isinstance(value, text_type):
        return value
    if isinstance(value, binary_type):
        for encoding in ("utf-8", "mbcs", "cp936", "gbk"):
            try:
                return value.decode(encoding)
            except Exception:
                pass
        try:
            return value.decode("utf-8", "replace")
        except Exception:
            return text_type(value)
    try:
        return text_type(value)
    except Exception:
        try:
            return text_type(value.Name)
        except Exception:
            return u""


def _write_text_file(path, content, mode="w"):
    with io.open(path, mode, encoding="utf-8", newline="") as stream:
        stream.write(_to_text(content))


def _utf8_hex(value):
    text = _to_text(value)
    data = text.encode("utf-8")
    try:
        return data.hex()
    except AttributeError:
        return "".join("{0:02x}".format(ord(ch)) for ch in data)


class Logger(object):
    def __init__(self, path):
        self.path = path

    def write(self, message):
        try:
            _write_text_file(self.path, _to_text(message) + u"\n", "a")
        except Exception:
            pass

    def section(self, title):
        self.write("")
        self.write("==== {0} ====".format(_to_text(title)))


def _safe_name(value):
    if value is None:
        return u""
    try:
        return _to_text(value)
    except Exception:
        try:
            return _to_text(value.Name)
        except Exception:
            return u""


def _obj_name(obj):
    for attr in ("Name", "name"):
        try:
            value = getattr(obj, attr)
            if value:
                return _safe_name(value)
        except Exception:
            pass
    for method_name in ("GetName", "AskName"):
        try:
            value = getattr(obj, method_name)()
            if value:
                return _safe_name(value)
        except Exception:
            pass
    try:
        return _safe_name(obj)
    except Exception:
        return u"<UNKNOWN>"


def _obj_type(obj):
    try:
        return obj.GetType().Name
    except Exception:
        pass
    try:
        return obj.__class__.__name__
    except Exception:
        return "<UNKNOWN>"


def _tag(obj):
    try:
        return int(obj.Tag)
    except Exception:
        return -1


def _tcl_quote(value):
    text = _safe_name(value)
    text = text.replace("\\", "\\\\")
    text = text.replace("{", "\\{").replace("}", "\\}")
    return "{" + text + "}"



def _existing_file(path):
    try:
        return path and os.path.isfile(path)
    except Exception:
        return False


def _env_value(session, name):
    for getter in (
        lambda: os.environ.get(name, ""),
        lambda: session.GetEnvironmentVariableValue(name),
    ):
        try:
            value = getter()
            if value:
                return value
        except Exception:
            pass
    return ""


def _script_directory():
    try:
        return os.path.dirname(os.path.abspath(__file__))
    except Exception:
        return os.getcwd()


def _ensure_men_files_gbk_ansi(log):
    """确保 NX MenuScript 文件 (.men/.rtb) 为 GBK(ANSI)+CRLF+无BOM 编码。

    NX 要求这些文件必须是 ANSI(GBK) 编码，UTF-8 存储会导致中文菜单乱码。
    本函数在每次 Journal 运行时检测并自动修正，保证进入 NX 后菜单正常显示。
    """
    script_dir = _script_directory()
    startup_dir = os.path.normpath(os.path.join(script_dir, "..", "startup"))
    target_names = ("smart_post.men", "smart_post.rtb")
    utf8_bom = b"\xef\xbb\xbf"

    for name in target_names:
        path = os.path.join(startup_dir, name)
        if not os.path.isfile(path):
            continue
        try:
            with open(path, "rb") as stream:
                data = stream.read()
        except Exception as exc:
            log.write("Skip {0}: cannot read ({1})".format(name, _safe_name(exc)))
            continue

        # 已是 GBK(ANSI)、无 UTF-8 BOM、且非纯 ASCII 时能按 GBK 解码 -> 跳过
        if data[:3] == utf8_bom:
            needs_fix = True
        else:
            try:
                data.decode("gbk")
                # 若能按 gbk 解码，视为已正确；但需排除“恰好也是合法 gbk 的纯 ASCII/UTF-8”情况：
                # 若同时能按 utf-8 解码且包含非 ASCII，说明可能是 UTF-8 误存，需要转 GBK。
                try:
                    data.decode("utf-8")
                    has_non_ascii = any(b > 127 for b in data)
                    needs_fix = has_non_ascii  # UTF-8 可解码且含中文 -> 实为 UTF-8，需转 GBK
                except Exception:
                    needs_fix = False  # 只能 gbk 解，已是 ANSI
            except Exception:
                needs_fix = True  # gbk 解不了，需尝试修复

        if not needs_fix:
            continue

        # 尝试修复：优先按 utf-8 解码（HEAD 版是正确 UTF-8 中文），再编码为 GBK+CRLF
        text = None
        for enc in ("utf-8", "utf-8-sig", "cp936", "gbk", "mbcs", "latin1"):
            try:
                text = data.decode(enc)
                break
            except Exception:
                pass
        if text is None:
            log.write("Skip {0}: cannot decode for repair".format(name))
            continue

        new_data = text.replace("\r\n", "\n").replace("\n", "\r\n").encode("gbk")
        try:
            with open(path, "wb") as stream:
                stream.write(new_data)
            log.write("Fixed encoding of {0} -> GBK(ANSI)+CRLF".format(name))
        except Exception as exc:
            log.write("Failed to rewrite {0}: {1}".format(name, _safe_name(exc)))


def _candidate_post_dirs(session, work_part, output_dir, log):
    script_dir = _script_directory()
    plugin_root = os.path.dirname(script_dir)
    dirs = []

    def add(path, label):
        if not path:
            return
        normalized = os.path.normpath(path)
        if normalized not in [item[0] for item in dirs]:
            dirs.append((normalized, label))

    add(script_dir, "script directory")
    add(plugin_root, "plugin root")
    add(output_dir, "part/output directory")

    cam_post_dir = _env_value(session, "UGII_CAM_POST_DIR")
    add(cam_post_dir, "UGII_CAM_POST_DIR")

    base_dir = _env_value(session, "UGII_BASE_DIR")
    if base_dir:
        add(os.path.join(base_dir, "mach", "resource", "postprocessor"), "UGII_BASE_DIR standard postprocessor")

    log.write("Post search dirs: {0}".format(["{0} ({1})".format(path, label) for path, label in dirs]))
    return dirs


def _post_template_line(post_name, tcl_path, def_path):
    return u"{0},{1},{2}".format(_safe_name(post_name), _safe_name(tcl_path), _safe_name(def_path))


def _read_file_best_effort(path):
    try:
        with open(path, "rb") as stream:
            data = stream.read()
    except Exception:
        return u""
    for encoding in ("utf-8", "mbcs", "cp936", "gbk", "latin1"):
        try:
            return data.decode(encoding)
        except Exception:
            pass
    try:
        return data.decode("utf-8", "ignore")
    except Exception:
        return u""


def _looks_like_template_post_entry(line):
    stripped = line.strip()
    if not stripped or stripped.startswith((";", "#", "!")):
        return False
    return len(stripped.split(",")) >= 3


def _insert_text_line_best_effort(path, line):
    try:
        existing = _read_file_best_effort(path)
        lines = existing.splitlines()
        insert_index = len(lines)
        for index, existing_line in enumerate(lines):
            if _looks_like_template_post_entry(existing_line):
                insert_index = index
                break

        if lines:
            lines.insert(insert_index, line)
            new_text = u"\r\n".join(lines) + u"\r\n"
        else:
            new_text = u"; NX postprocessor template file\r\n" + line + u"\r\n"

        if os.path.exists(path):
            try:
                os.chmod(path, 0o666)
            except Exception:
                pass
        else:
            parent = os.path.dirname(path)
            if parent and not os.path.isdir(parent):
                os.makedirs(parent)

        with open(path, "wb") as stream:
            stream.write(new_text.encode("utf-8"))
        return True, ""
    except Exception as exc:
        return False, _safe_name(exc)


def _template_post_paths(session, post_name):
    cam_post_dir = _env_value(session, "UGII_CAM_POST_DIR")
    if not cam_post_dir:
        return "", "", "", ""
    template_path = os.path.join(cam_post_dir, "template_post.dat")
    tcl_path = os.path.join(cam_post_dir, post_name + ".tcl")
    def_path = os.path.join(cam_post_dir, post_name + ".def")
    return cam_post_dir, template_path, tcl_path, def_path


def _ensure_template_post_registration(session, post_name, fallback_tcl_path, fallback_def_path, log):
    cam_post_dir, template_path, standard_tcl_path, standard_def_path = _template_post_paths(session, post_name)
    if not cam_post_dir:
        log.write("UGII_CAM_POST_DIR is empty; cannot update template_post.dat automatically.")
        return False

    # Register the standard postprocessor directory first. NX12 resolves registered
    # post names most reliably from UGII_CAM_POST_DIR/template_post.dat.
    if _existing_file(standard_tcl_path) and _existing_file(standard_def_path):
        tcl_path = standard_tcl_path
        def_path = standard_def_path
        tcl_for_template = "${UGII_CAM_POST_DIR}" + os.path.basename(standard_tcl_path)
        def_for_template = "${UGII_CAM_POST_DIR}" + os.path.basename(standard_def_path)
    elif _existing_file(fallback_tcl_path) and _existing_file(fallback_def_path):
        tcl_path = fallback_tcl_path
        def_path = fallback_def_path
        tcl_for_template = fallback_tcl_path
        def_for_template = fallback_def_path
    else:
        log.write("Cannot register {0}: .tcl/.def pair not found. standard=({1}, {2}) fallback=({3}, {4})".format(
            post_name, standard_tcl_path, standard_def_path, fallback_tcl_path, fallback_def_path))
        return False

    log.write("template_post.dat target: {0}".format(template_path))
    log.write("template_post.dat source files: {0} | {1}".format(tcl_path, def_path))

    existing = _read_file_best_effort(template_path)
    for line in existing.splitlines():
        fields = [field.strip().lower() for field in line.split(",")]
        if fields and fields[0] == post_name.lower():
            log.write("template_post.dat already has registered post name {0}: {1}".format(post_name, template_path))
            return True

    line = _post_template_line(post_name, tcl_for_template, def_for_template)
    ok, err = _insert_text_line_best_effort(template_path, line)
    if ok:
        verify_text = _read_file_best_effort(template_path)
        if line.lower() in verify_text.lower():
            log.write("Registered {0} before first template_post.dat entry: {1}".format(post_name, line))
            return True
        log.write("Tried to register {0}, but verification did not find appended line: {1}".format(post_name, line))
        return False

    log.write("Failed to update template_post.dat automatically: {0}".format(err))
    return False


def _resolve_post_name(session, work_part, output_dir, log):
    # NX12 后处理只允许一次实际调用；不要把注册名和物理 .tcl 路径都作为候选反复试。
    # 更名为 smart_post 后，只在找到文件时尝试注册，随后优先用注册名调用；
    # 若无法注册/找不到文件，再退回旧逻辑使用物理路径或注册名。
    first_physical = ""
    found_pair = False
    registration_ok = False

    for directory, label in _candidate_post_dirs(session, work_part, output_dir, log):
        tcl_path = os.path.join(directory, POST_NAME + ".tcl")
        def_path = os.path.join(directory, POST_NAME + ".def")
        if _existing_file(tcl_path):
            if not first_physical:
                first_physical = tcl_path
            if _existing_file(def_path):
                found_pair = True
                log.write("Resolved post files by {0}: {1} with {2}".format(label, tcl_path, def_path))
                registration_ok = _ensure_template_post_registration(session, POST_NAME, tcl_path, def_path, log)
                break
            log.write("Resolved post Tcl by {0}: {1}; matching .def not found beside it".format(label, tcl_path))

    if not found_pair:
        cam_post_dir, template_path, standard_tcl_path, standard_def_path = _template_post_paths(session, POST_NAME)
        if cam_post_dir:
            log.write("No physical post pair found during directory scan; trying standard registration paths anyway.")
            registration_ok = _ensure_template_post_registration(session, POST_NAME, standard_tcl_path, standard_def_path, log)

    if registration_ok:
        log.write("Resolved post by registered name: {0}".format(POST_NAME))
        return POST_NAME
    if first_physical:
        log.write("Resolved post by physical Tcl path: {0}".format(first_physical))
        return first_physical
    log.write("Physical post file not found; falling back to registered post name: {0}".format(POST_NAME))
    return POST_NAME

def _part_base_name(work_part):
    candidates = []
    for attr in ("FullPath", "FullPathName"):
        try:
            value = getattr(work_part, attr)
            if value:
                root = os.path.splitext(os.path.basename(value))[0]
                if root:
                    candidates.append(root)
        except Exception:
            pass
    for attr in ("Name", "Leaf"):
        try:
            value = getattr(work_part, attr)
            if value:
                root = os.path.splitext(os.path.basename(value))[0]
                if root:
                    candidates.append(root)
        except Exception:
            pass
    for candidate in candidates:
        text = _safe_name(candidate).strip()
        if text:
            return text
    return u""


def _part_directory(work_part):
    candidates = []
    for attr in ("FullPath", "FullPathName"):
        try:
            value = getattr(work_part, attr)
            if value:
                candidates.append(value)
        except Exception:
            pass
    for attr in ("Name", "Leaf"):
        try:
            value = getattr(work_part, attr)
            if value:
                candidates.append(value)
        except Exception:
            pass
    for path in candidates:
        try:
            directory = os.path.dirname(path)
            if directory and os.path.isdir(directory):
                return directory
        except Exception:
            pass
    return os.getcwd()


def _selected_objects(session, log):
    selected = []
    try:
        selection_manager = session.GetUI().SelectionManager
    except Exception:
        try:
            selection_manager = NXOpen.UI.GetUI().SelectionManager
        except Exception as exc:
            log.write("SelectionManager unavailable: {0}".format(exc))
            return selected

    for attr in ("GetNumSelectedObjects", "GetNumSelected"):
        try:
            count = getattr(selection_manager, attr)()
            break
        except Exception:
            count = 0
    else:
        count = 0

    for index in range(count):
        for method_name in ("GetSelectedTaggedObject", "GetSelectedObject"):
            try:
                obj = getattr(selection_manager, method_name)(index)
                if obj is not None:
                    selected.append(obj)
                    break
            except Exception:
                pass
    return selected


def _children(obj):
    result = []
    for method_name in ("GetMembers", "GetChildren", "GetObjects", "GetOperations", "GetGroups"):
        try:
            values = getattr(obj, method_name)()
            if values:
                for child in values:
                    if child is not None and child not in result:
                        result.append(child)
        except Exception:
            pass
    for attr in ("Members", "Children"):
        try:
            values = getattr(obj, attr)
            if values:
                for child in values:
                    if child is not None and child not in result:
                        result.append(child)
        except Exception:
            pass
    return result


def _append_unique(items, value):
    if value is not None and value not in items:
        items.append(value)


def _call_noargs(owner, method_name):
    try:
        method = getattr(owner, method_name)
    except Exception:
        return None
    try:
        return method()
    except Exception:
        return None


def _collection_values(collection):
    values = []
    if collection is None:
        return values

    for method_name in (
        "ToArray",
        "GetContents",
        "GetMembers",
        "GetObjects",
        "GetChildren",
        "GetRootGroups",
    ):
        result = _call_noargs(collection, method_name)
        if result:
            try:
                for item in result:
                    _append_unique(values, item)
            except Exception:
                _append_unique(values, result)

    for attr in ("Root", "RootGroup", "ProgramRoot", "ProgramOrderRoot"):
        try:
            _append_unique(values, getattr(collection, attr))
        except Exception:
            pass

    try:
        for item in collection:
            _append_unique(values, item)
    except Exception:
        pass

    return values


def _find_named_cam_group(collection, names, log):
    if collection is None:
        return None
    for method_name in ("FindObject", "Find", "GetObject", "GetObjectFromName"):
        try:
            method = getattr(collection, method_name)
        except Exception:
            continue
        for name in names:
            try:
                obj = method(name)
                if obj is not None:
                    log.write("Found CAM root by {0}({1})".format(method_name, name))
                    return obj
            except Exception:
                pass
    return None


def _parent(obj):
    for method_name in ("GetParent", "GetParentGroup", "AskParent"):
        parent = _call_noargs(obj, method_name)
        if parent is not None:
            return parent
    for attr in ("Parent", "ParentGroup", "OwningGroup"):
        try:
            parent = getattr(obj, attr)
            if parent is not None:
                return parent
        except Exception:
            pass
    return None


def _topological_roots(items):
    roots = []
    item_set = []
    for item in items:
        _append_unique(item_set, item)

    child_set = []
    for item in item_set:
        for child in _children(item):
            _append_unique(child_set, child)

    for item in item_set:
        parent = _parent(item)
        if parent is not None and parent in item_set:
            continue
        if item in child_set:
            continue
        _append_unique(roots, item)

    if not roots:
        for item in item_set:
            if _children(item):
                _append_unique(roots, item)
    return roots


def _all_cam_roots(setup, log):
    roots = []
    collection_items = []

    for method_name in (
        "GetRootProgramGroup",
        "GetRootCAMGroup",
        "GetRootMcsGroup",
        "GetRootGeometryGroup",
        "GetRootMethodGroup",
        "GetRootToolGroup",
        "GetProgramRoot",
        "GetRootGroup",
    ):
        root = _call_noargs(setup, method_name)
        _append_unique(roots, root)

    for attr in (
        "RootProgramGroup",
        "RootCAMGroup",
        "ProgramRoot",
        "ProgramOrderRoot",
        "RootGroup",
    ):
        try:
            _append_unique(roots, getattr(setup, attr))
        except Exception:
            pass

    collections = []
    for attr in ("CAMGroupCollection", "ProgramOrderView", "ProgramView", "CAMGroups"):
        try:
            value = getattr(setup, attr)
            if callable(value):
                try:
                    value = value()
                except Exception:
                    pass
            _append_unique(collections, value)
        except Exception:
            pass

    for collection in collections:
        for item in _collection_values(collection):
            _append_unique(collection_items, item)

    for root in _topological_roots(collection_items):
        _append_unique(roots, root)

    if not roots:
        # Last-resort compatibility fallback only. Some NX12 installs expose the
        # Program View root through CAMGroupCollection.FindObject but not through
        # enumerable root APIs. The main path above remains topology/API based.
        preferred_names = ("NC_PROGRAM", "PROGRAM", "Program", "program")
        for collection in collections:
            _append_unique(roots, _find_named_cam_group(collection, preferred_names, log))

    log.write("Root candidates: {0}".format([_obj_name(root) for root in roots]))
    return roots


def _is_cam_program_group(obj):
    type_name = _safe_name(_obj_type(obj))
    if type_name and "NCGroup" in type_name:
        return True
    # Some NXOpen wrappers expose all CAM groups with a generic class name.
    # Treat objects with child CAM members as program group candidates here;
    # tool/method roots are filtered out later by name/type/logical children when possible.
    return False


def _find_program_root(setup, log):
    # Prefer an actual topological Program View root. If NX exposes only the
    # top-level program groups and not their hidden parent, return the whole list
    # so postprocess receives all groups instead of just the first one.
    roots = _all_cam_roots(setup, log)
    if not roots:
        return None

    child_roots = [root for root in roots if _children(root)]
    program_group_roots = [root for root in child_roots if _is_cam_program_group(root)]

    if len(program_group_roots) > 1:
        log.write("No single CAM root exposed; using top-level program groups: {0}".format([_obj_name(root) for root in program_group_roots]))
        return program_group_roots

    if len(program_group_roots) == 1:
        return program_group_roots[0]

    if child_roots:
        log.write("No NCGroup root type exposed; using child-bearing roots: {0}".format([_obj_name(root) for root in child_roots]))
        if len(child_roots) > 1:
            return child_roots
        return child_roots[0]

    return roots[0]


def _target_display_name(target):
    if isinstance(target, (list, tuple)):
        return "NC_PROGRAM"
    return _obj_name(target)


def _walk(root):
    records = []
    visited = set()

    def visit(obj, parent, depth, path):
        tag = _tag(obj)
        if tag in visited:
            return
        visited.add(tag)
        name = _obj_name(obj)
        obj_path = path + [name]
        records.append({
            "tag": tag,
            "name": name,
            "parent": parent,
            "depth": depth,
            "path": obj_path,
            "type": _obj_type(obj),
            "object": obj,
        })
        for child in _children(obj):
            visit(child, name, depth + 1, obj_path)

    if isinstance(root, (list, tuple)):
        records.append({
            "tag": -1,
            "name": "NC_PROGRAM",
            "parent": "NONE",
            "depth": 0,
            "path": ["NC_PROGRAM"],
            "type": "NCGroup",
            "object": None,
        })
        for item in root:
            visit(item, "NC_PROGRAM", 1, ["NC_PROGRAM"])
    elif root is not None:
        visit(root, "NONE", 0, [])
    return records



def _write_hierarchy_cache(path, selected_root, records, log):
    lines = [
        u"# Auto-generated by get_cam_hierarchy_and_post.py. Do not edit.",
        u"catch { unset nx_cam_parent }",
        u"catch { unset nx_cam_path }",
        u"catch { unset nx_cam_type }",
        u"catch { unset nx_cam_depth }",
        u"array set nx_cam_parent {}",
        u"array set nx_cam_path {}",
        u"array set nx_cam_type {}",
        u"array set nx_cam_depth {}",
        u"set nx_cam_selected_root {0}".format(_tcl_quote(_target_display_name(selected_root))),
        u"set nx_cam_root_parent {NONE}",
    ]
    for item in records:
        name = item["name"]
        lines.append(u"set nx_cam_parent({0}) {1}".format(_tcl_quote(name), _tcl_quote(item["parent"])))
        lines.append(u"set nx_cam_path({0}) {1}".format(_tcl_quote(name), _tcl_quote(u"/".join(item["path"]))))
        lines.append(u"set nx_cam_type({0}) {1}".format(_tcl_quote(name), _tcl_quote(item["type"])))
        lines.append(u"set nx_cam_depth({0}) {1}".format(_tcl_quote(name), int(item["depth"])))
    _write_text_file(path, u"\n".join(lines) + u"\n")
    log.write("Hierarchy cache written: {0}".format(_safe_name(path)))


def _choose_target(session, setup, log):
    selected = _selected_objects(session, log)
    if selected:
        log.write("Selected objects: {0}".format([_obj_name(obj) for obj in selected]))
        return selected[0]
    root = _find_program_root(setup, log)
    if isinstance(root, (list, tuple)):
        log.write("No CAM object selected; fallback topological roots: {0}".format([_obj_name(item) for item in root]))
    else:
        log.write("No CAM object selected; fallback topological root: {0}".format(_obj_name(root)))
    return root


def _cam_output_units_metric(log):
    output_units = getattr(NXOpen.CAM.CAMSetup, "OutputUnits", None)
    if output_units is None:
        log.write("CAMSetup.OutputUnits enum is not available in this NX version.")
        return None
    for attr_name in ("OutputUnitsMetric", "Metric", "Millimeter"):
        value = getattr(output_units, attr_name, None)
        if value is not None:
            log.write("Using CAM output units enum: {0}".format(attr_name))
            return value
    log.write("No supported metric output units enum found on CAMSetup.OutputUnits.")
    return None


def _postprocess_one(setup, target, post_name, output_path, log):
    errors = []
    method_names = ("Postprocess", "PostProcess", "PostprocessWithSetting")
    metric_units = _cam_output_units_metric(log)
    singleton_targets = [target]
    arg_sets = []
    if metric_units is not None:
        arg_sets.append((singleton_targets, post_name, output_path, metric_units))
        arg_sets.append((target, post_name, output_path, metric_units))
    arg_sets.append((singleton_targets, post_name, output_path))
    arg_sets.append((target, post_name, output_path))
    for method_name in method_names:
        method = getattr(setup, method_name, None)
        if method is None:
            continue
        for args in arg_sets:
            try:
                log.write("Trying {0} with post {1}: {2}".format(method_name, post_name, tuple(type(arg).__name__ for arg in args)))
                method(*args)
                log.write("Postprocess succeeded: {0}".format(output_path))
                return True
            except Exception as exc:
                errors.append("{0} ({1}): {2}".format(method_name, post_name, exc))
    log.write("Postprocess API attempts failed:")
    for err in errors:
        log.write("  " + err)
    return False


def _postprocess(setup, target, post_name, output_path, log):
    if not isinstance(target, (list, tuple)):
        return _postprocess_one(setup, target, post_name, output_path, log)

    all_ok = True
    output_dir = os.path.dirname(output_path)
    batch_total = len(target)
    log.write("Postprocessing fallback roots one by one: {0}".format([_obj_name(item) for item in target]))
    # 批量处理期间保留环境变量，直到全部完成后才清除。
    # 这样 Tcl 后处理器在每个 MOM_end_of_program 中都能正确识别批量状态，
    # 避免除最后一个对象外重复弹出输出目录。
    try:
        for index, item in enumerate(target, 1):
            os.environ["NX_SMART_POST_BATCH_TOTAL"] = str(batch_total)
            os.environ["NX_SMART_POST_BATCH_INDEX"] = str(index)
            item_name = _target_display_name(item) or "CAM_ROOT"
            item_output_path = os.path.join(output_dir, item_name + OUTPUT_EXT)
            log.write("Postprocess batch item {0}/{1}: {2}".format(index, batch_total, item_name))
            if not _postprocess_one(setup, item, post_name, item_output_path, log):
                all_ok = False
    finally:
        os.environ.pop("NX_SMART_POST_BATCH_TOTAL", None)
        os.environ.pop("NX_SMART_POST_BATCH_INDEX", None)
    return all_ok


def main():
    session = NXOpen.Session.GetSession()
    work_part = session.Parts.Work
    if work_part is None:
        raise RuntimeError("No work part is open.")

    output_dir = _part_directory(work_part)
    log = Logger(os.path.join(output_dir, LOG_NAME))
    log.section("NX Smart Post Journal")

    # 进入 NX 运行 Journal 时，自动确保 MenuScript 文件为 GBK(ANSI) 编码，
    # 避免中文菜单因 UTF-8 存储而乱码。
    _ensure_men_files_gbk_ansi(log)

    setup = work_part.CAMSetup
    if setup is None:
        raise RuntimeError("The current work part has no CAM setup.")

    target = _choose_target(session, setup, log)
    if target is None:
        raise RuntimeError("Cannot find selected CAM object or topological fallback root.")

    records = _walk(target)
    cache_path = os.path.join(output_dir, HIERARCHY_CACHE_NAME)
    _write_hierarchy_cache(cache_path, target, records, log)

    part_base_name = _part_base_name(work_part)
    if part_base_name:
        os.environ["NX_SMART_POST_PART_NAME"] = part_base_name
        os.environ["NX_SMART_POST_PART_NAME_UTF8_HEX"] = _utf8_hex(part_base_name)
        log.write("Part output folder name: {0}".format(part_base_name))

    target_name = _target_display_name(target) or "CAM_ROOT"
    output_path = os.path.join(output_dir, target_name + OUTPUT_EXT)

    # Tell the Tcl post this hierarchy cache belongs to the current automatic run.
    # A normal NX postprocess command will not set this variable, so stale cache files
    # are ignored and the post falls back to native MOM group events.
    os.environ["NX_SMART_POST_USE_CACHE"] = "1"
    resolved_post = _resolve_post_name(session, work_part, output_dir, log)
    ok = _postprocess(setup, target, resolved_post, output_path, log)
    if not ok:
        log.write("Automatic postprocess was not completed; hierarchy cache is still available.")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        try:
            session = NXOpen.Session.GetSession()
            work_part = session.Parts.Work
            output_dir = _part_directory(work_part) if work_part is not None else os.getcwd()
            Logger(os.path.join(output_dir, LOG_NAME)).write(traceback.format_exc())
        except Exception:
            pass
        raise