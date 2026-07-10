# NX12 智能后处理器

本项目用于 Siemens NX 12.0.2.x 三轴铣后处理，目标机床为无刀库机床。最终实现由 Python Journal 与 Tcl 后处理器配合完成：Python 负责读取/缓存 CAM 层级并发起后处理，Tcl 负责按层级智能路由、拆分/合并 NC、保留 NX “列出输出”窗口中的 NC 代码显示，并在结束后清理临时预览文件。

## 当前文件

- `smart_post.tcl` / `smart_post.tcl.tex`：当前正式后处理器逻辑。
- `NX_Smart_Post/application/get_cam_hierarchy_and_post.py`：NX Journal 自动后处理入口。
- `1111.tcl`：稳定参考基线，只作对照和回退，不建议修改。
- `smart_post.def`、`smart_post.pui`：Post Builder 配置文件。
- `smart_post_user.tcl`：用户扩展入口。
- `Original/`：原始备份。

## 工作流程

1. 在 NX 中打开包含 CAM 的部件。
2. 选中 `NC_PROGRAM`、一级程序组、二级组或单个工序。
3. 执行 `NX_Smart_Post/application/get_cam_hierarchy_and_post.py` Journal。
4. Journal 生成 `nx_cam_hierarchy.tcl`，设置必要环境变量，并调用配置的后处理器。
5. Tcl 后处理器读取本次层级缓存，按最终 CAM 层级输出 NC 文件。
6. 后处理结束后打开或聚焦部件名总输出目录，并后台延迟清理临时预览文件。

## 默认后处理器配置

Python Journal 默认调用 `smart_post`：

```python
DEFAULT_POST_NAME = "smart_post"
POST_NAME = os.environ.get("NX_SMART_POST_NAME", DEFAULT_POST_NAME)
```

后续更换后处理器时，优先修改 `get_cam_hierarchy_and_post.py` 文件头的 `DEFAULT_POST_NAME`。临时测试也可通过环境变量 `NX_SMART_POST_NAME` 覆盖。

## 输出目录规则

总输出目录固定为：

```text
部件所在目录/部件名/
```

部件名优先由 Python Journal 通过 `NX_SMART_POST_PART_NAME_UTF8_HEX` / `NX_SMART_POST_PART_NAME` 传给 Tcl；若直接使用 NX 原生后处理命令，则 Tcl 从 MOM 变量、原始输出文件名等信息兜底推断。

## CAM 层级输出规则

- 选中 `NC_PROGRAM`：一级组生成文件夹；一级组下独立工序单独输出；二级组输出单一合并 NC。
- 选中一级组：只输出该组下的独立工序和二级组合并 NC。
- 选中单工序：输出到所属一级组目录，文件名为工序名。
- 选中二级组：输出到所属一级组目录，文件名为二级组名，组内工序合并。
- 多层管理组会保留为目录层级，但不会强制把一级组整体合并成一个 NC。
- 不默认生成“每个一级程序组一个合并 NC 文件”。

示例：

```text
部件名/
├── TOP/
│   ├── TOP-01.nc
│   ├── TOP-02.nc
│   └── TOP-03.nc
├── RIG/
│   ├── RIG-01.nc
│   └── RIG-02.nc
└── LEFT/
    ├── LEFT-01.nc
    └── LEFT-02.nc
```

## Python Journal 实现要点

`get_cam_hierarchy_and_post.py` 的职责：

- 读取当前 NX Session 和工作部件。
- 获取用户当前选择的 CAM 对象；没有选择时回退到程序根。
- 遍历 CAM 程序组树，写出 `nx_cam_hierarchy.tcl`。
- 设置 `NX_SMART_POST_USE_CACHE=1`，避免 Tcl 误用旧缓存。
- 设置部件名环境变量，确保中文部件名目录稳定。
- 解析单个后处理器：找到 `.tcl/.def` 后先尝试注册 `POST_NAME`，成功则用注册名调用；否则仅兜底使用一个物理 `.tcl` 路径。
- 兼容 NXOpen 不同版本的 `Postprocess` / `PostProcess` / `PostprocessWithSetting` 调用形式。
- 批量回退处理多个根对象时设置 `NX_SMART_POST_BATCH_INDEX` 和 `NX_SMART_POST_BATCH_TOTAL`。

## Tcl 后处理器实现要点

`smart_post.tcl.tex` 的职责：

- 通过 `rename` Hook 关键 MOM 事件，避免 Post Builder 覆盖自定义逻辑。
- 在 `MOM_start_of_path` 前执行智能文件切换，并继续调用原始 `MOM_start_of_path_orig` 保留机床初始化。
- 维护程序组栈和层级映射，优先使用 Journal 本次生成的层级缓存。
- 根据层级决定输出目录和文件名，并维护合法 NC 白名单。
- 二级组合并时只保留单一程序头/尾。
- 使用刀具指纹校验，避免无刀库机床在同一合并文件中混入不同刀具。
- 在 `MOM_end_of_program` 统一收尾、打开输出目录、恢复原始输出句柄。
- 在 `CLOSE_files` 中延迟清理临时汇总 NC、同名 `.ptp` 和 `.lpt`。

## “列出输出”与临时汇总 NC

NX “列出输出/信息窗口”显示 NC 代码时，关键依赖主 `ptp_file_name` 对应的 NC 输出流。`.lpt` 是 listing/commentary 报告文件，不是 NC 代码显示的根来源。

因此当前实现必须保留这条链路：

- 原始输出文件（例如 `部件名.nc` 或 NX 生成的临时主输出文件）短暂作为汇总 NC/预览文件存在。
- `PB_CMD_before_output` 把每行 `mom_o_buffer` 镜像写入 `my_original_ptp_chan`。
- NX 信息窗口读取该临时汇总 NC 显示代码。
- 后处理结束后再后台延迟删除临时 `.nc`、同名 `.ptp` 和 `.lpt`。

不要把这条链路改成“只有勾选列出输出才维护”，也不要试图用 `.lpt` 追加内容替代主 NC 预览文件。

## 清理策略

- 勾选“列出输出”：默认等待 `10000 ms` 后清理，保证 NX 有时间读取临时汇总 NC。
- 未勾选“列出输出”：默认等待 `1000 ms` 后清理，减少临时文件可见时间。
- 可通过 Tcl 全局变量 `my_cleanup_delay_ms` 覆盖等待时间。
- Windows 下生成隐藏 `.vbs` 启动 `.cmd`，用 `wscript.exe //B //Nologo` 避免命令行窗口闪现。
- `.cmd` 内部对目标文件做重试删除；`.lpt` 重试次数较少，`.nc/.ptp` 更保守。
- Unix/Linux 下使用后台 `sh -c` 延迟 `rm -f`。
- 清理日志：`%TEMP%/nx_cleanup_latest.log`。

成功日志常见片段：

```text
After delay ...
Target: ...部件名.nc
DELETED_OR_NOT_EXIST: ...部件名.nc
```

## 打开输出目录

- Python Journal 批量后处理时通过 `NX_SMART_POST_BATCH_INDEX` / `NX_SMART_POST_BATCH_TOTAL` 告诉 Tcl 当前序号；Tcl 只在最后一个对象结束后打开目录。
- 直接使用 NX 原生后处理命令时没有批量变量；Tcl 使用 `NX_SMART_POST_OPENED_OUTPUT_DIR` 和 `NX_SMART_POST_OPENED_OUTPUT_TIME_MS` 做短时间去重。
- Windows 下优先聚焦已打开的目标资源管理器窗口，否则打开新窗口。

## 调试

智能路由 debug 默认关闭。需要排障时可设置：

```text
NX_SMART_ROUTE_DEBUG=1
```

或在 Tcl 中预设：

```tcl
set my_smart_route_debug 1
```

常用日志：

- `nx_smart_post_journal.log`：Python Journal 日志，位于部件目录。
- `nx_cam_hierarchy.tcl`：Python 导出的本次 CAM 层级缓存，位于部件目录。
- `%TEMP%/nx_cleanup_latest.log`：后台清理日志。

## 验证建议

Python 语法验证：

```bash
python -m py_compile NX12POST/NX_Smart_Post/application/get_cam_hierarchy_and_post.py
```

LaTeX 文档验证：

```bash
pdflatex main.tex
```

NX12 实机复测重点：

- 选中 `NC_PROGRAM`。
- 选中单个一级组。
- 选中二级组。
- 选中单个工序。
- 多层管理组路径。
- 勾选与不勾选“列出输出”。
- 自动 Journal 与 NX 原生后处理两种入口。

## 常见问题

### “列出输出”没有 NC 代码

优先检查：

- `my_original_ptp_chan` 是否仍存在并保持打开。
- `PB_CMD_before_output` 是否仍向 `my_original_ptp_chan` 写入 `mom_o_buffer`。
- 是否误把原始汇总 NC 链路限制为“只有勾选列出输出才启用”。
- 是否引入了用 `.lpt` 替代主 NC 预览文件的旧逻辑。

### 未勾选“列出输出”仍短暂生成部件名 NC

这是正常行为。该文件是 NX 主输出预览链路的一部分，当前会在约 `1s` 后后台清理。

### 清理文件没有删除

查看 `%TEMP%/nx_cleanup_latest.log`：

- 有 `Scheduled cleanup script` 但没有 `After delay`：隐藏启动器或系统策略可能阻止脚本启动。
- 有 `After delay` 但显示 `FAILED_LOCKED_OR_IN_USE`：NX、杀软或其他进程仍占用文件。
- 显示 `DELETED_OR_NOT_EXIST`：清理成功或目标已不存在。

### 修改后 NX 没生效

NX 可能缓存后处理 Tcl。修改 `.tcl` 后，建议重启 NX 再测试。

## 常见错误码

- `1745006`：Invalid block template name，通常是 `MOM_do_template` 调用了不存在的模板。
- `1745007`：Invalid expression in block template，通常是 DEF 中 Text 表达式错误。
- `1770002`：Tcl interpreter error，通常是 Tcl 运行错误的通用包装。