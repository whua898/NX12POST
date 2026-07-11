# NX Smart Post - 维护者说明

本文档面向**维护者**。面向**操作者**的说明见 [`README.md`](./README.md)。

## 项目结构与职责

| 角色 | 文件 | 职责 |
|---|---|---|
| Tcl 正式后处理器 | `smart_post.tcl` / `smart_post.tcl.tex` | Hook NX/Post Builder 的 MOM 事件；在每个工序开始前切换目标 NC；写程序头、程序尾；维护临时主输出文件镜像链路；统一收尾、清理、打开输出目录 |
| Python Journal 入口 | `NX_Smart_Post/application/get_cam_hierarchy_and_post.py` | 读取/缓存 CAM 层级并发起后处理 |
| 用户扩展 | `smart_post_user.tcl` | 不会被 Post Builder 覆盖；承载打开目录、加载缓存、P1 新变量默认值、用户设置 helper |
| 稳定基线/参考 | `1111.tcl`、`Original/`、`ugpost_base.tcl` | 只读，不要修改 |

## 运行链路

```
用户在 NX 中打开包含 CAM 的部件
  → 选中 NC_PROGRAM / 一级组 / 二级组 / 单工序
  → 执行 Python Journal: get_cam_hierarchy_and_post.py
  → Journal 生成 nx_cam_hierarchy.tcl
  → Journal 设置环境变量 (NX_SMART_POST_*)
  → Journal 调用 smart_post 后处理器
  → Tcl 根据缓存或 MOM 事件维护组层级
  → Tcl 按层级拆分/合并 NC 文件
  → 结束后 Tcl 打开输出目录并延迟清理临时预览文件
```

## 环境变量表（由 Python Journal 设置）

| 变量 | 作用 | 何时读取 |
|---|---|---|
| `NX_SMART_POST_USE_CACHE` | `"1"` 表示本次缓存有效；普通 NX 后处理不设置，避免误读历史 | Tcl 加载 `nx_cam_hierarchy.tcl` 前 |
| `NX_SMART_POST_PART_NAME` | 部件名，用作输出总目录名 | Tcl 初始化 `my_out_dir` |
| `NX_SMART_POST_PART_NAME_UTF8_HEX` | 部件名的 UTF-8 hex，Tcl 端稳定还原中文部件名 | Tcl 初始化 `my_out_dir` |
| `NX_SMART_POST_BATCH_TOTAL` | 批量对象总数 | Tcl 在 `MOM_end_of_program` 中判断是否最后一个对象 |
| `NX_SMART_POST_BATCH_INDEX` | 当前批量对象下标 | 同上 |
| `NX_SMART_POST_NO_REGISTER` | `"1"` 跳过改写 `template_post.dat`（PR1 新增） | Python Journal 调用 `_ensure_template_post_registration` 前 |

## Tcl 用户配置变量

P1 新增的 4 个变量已迁移到 helper：

| 变量 | Helper 入口 | 默认值 |
|---|---|---|
| `NX_SMART_POST_FILENAME_MODE` | `PB_CMD_user_filename_mode_default` | `operation_tool` |
| `NX_SMART_POST_ABORT_ON_TOOL_MISMATCH` | `PB_CMD_user_abort_on_mismatch_default` | `0` |
| `NX_SMART_POST_KEEP_TEMP` | `PB_CMD_user_disable_temp_cleanup_default` | `0` |
| `NX_SMART_POST_AUTO_OPEN_DIR` | `PB_CMD_user_auto_open_dir_default` | `1` |

Legacy 变量（如 `my_smart_route_debug`、`my_output_operation_separator`、`my_cleanup_delay_ms`、`my_include_date_in_header` 等）仍直接在各 proc 中通过 `global` 读取，可读性强但分散。后续如需迁移到 helper，参考 PR3 的保守模式。

## Hook MOM 事件机制

`smart_post.tcl` 在初始化阶段 Hook 了 `MOM_start_of_group`、`MOM_end_of_group`、`MOM_start_of_path`。先把原始命令 rename 成 `*_orig`，再定义同名 wrapper，从而插入智能逻辑同时保留原始后处理行为。

关键在 `MOM_start_of_path`：

1. 先执行 `PB_CMD_smart_file_switch`
2. 文件切换失败则 abort
3. 按需写入程序头
4. 二级组合并时输出工序分隔注释
5. 最后调用 `MOM_start_of_path_orig`，保留机床状态和刀具初始化

这是"智能路由"插入点。

## 预览链路禁区（高风险核心）

`my_original_ptp_chan` 链路绝对不能破坏：

- 当检测到 NX 原始组合输出文件时，不删除它，而是打开 append 句柄 `my_original_ptp_chan`
- `PB_CMD_before_output` 把每行 `mom_o_buffer` 镜像写入 `my_original_ptp_chan` 并 flush
- `CLOSE_files` 关闭该句柄，并把原始 `.nc/.ptp/.lpt` 纳入延迟清理

这条链路是 NX 信息窗口能看到 NC 代码的关键。后续维护时：**不要改成"只有勾选列出输出才维护"**，也不能用 `.lpt` 替代主 NC 文件。

## 文件清理机制

- `CLOSE_files` 被重定义，增强防御并处理临时文件清理
- 清理目标：`my_cleanup_files`、原始主输出文件、同名 `.ptp` 或 `.nc` sibling、`.lpt` listing 文件
- 延迟策略：勾选"列出输出"默认 10000 ms；未勾选默认 1000 ms；勾选但手工 < 10000 ms 时强制提升到 10000 ms
- 清理日志：`%TEMP%/nx_cleanup_latest.log`

## 文件名清理

统一 helper 在 `smart_post.tcl` 中的 `PB_CMD_sanitize_file_component { value fallback }`。现有两个旧 proc：

- `PB_CMD_sanitize_filename` 已委托给 helper（PR2）
- `PB_CMD_smart_safe_folder_name` 仍然独立，未来可继续委托

## 修改禁区

- 不要删除 `my_original_ptp_chain` 链路
- 不要删除 `PB_CMD_before_output`
- 不要提前删除主输出 `.nc/.ptp/.lpt`
- 不要用 `.lpt` 替代主 NC 预览
- 不要让普通 NX 后处理读取旧 `nx_cam_hierarchy.tcl`（靠 `NX_SMART_POST_USE_CACHE` 控制）
- 不要默认生成一级组总合并 NC（当前规则：一级组目录化，二级组才合并）
- 不要修改 `1111.tcl`、`Original/`、`ugpost_base.tcl`

## 开发环境

- Python: 项目根的 `.venv/Scripts/python.exe`（用 `python -m venv .venv --clear` 重建）
- Tcl 语法检查: `D:\Program Files\Git\mingw64\bin\tclsh.exe`
- 加载测试: `tclsh smart_post.tcl`（`MOM_*` 等 NX 运行期命令会报 `invalid command name`，这是预期的）
- 完整加载顺序测试: `echo 'source smart_post.tcl' | tclsh`（会自动 source `smart_post_user.tcl`）
- Python 语法检查: `.venv/Scripts/python.exe -m py_compile NX_Smart_Post/application/get_cam_hierarchy_and_post.py`

## 同步到 NX

每次改动完毕 → 运行 `copy_to_nx_smart_post.bat`（或在 cmd 中 `cmd.exe /c copy_to_nx_smart_post.bat`）。bat 把 4 个文件（`smart_post.tcl`、`smart_post.def`、`smart_post.pui`、`smart_post_user.tcl`）复制到两处：

- `E:\Siemens\NX_Smart_Post\application\`（菜单 / Journal 目录）
- `E:\Siemens\NX 12.0\MACH\resource\postprocessor\`（真实后处理目录）

NX **不会缓存**后处理 Tcl，同步后下一次后处理立即生效。

## 回归测试

改动 Tcl 路由逻辑后，必须按 README "验收矩阵" 全场景回归。最小集：NC_PROGRAM (A) + 单工序 (D) + 二级组 (C)。

尤其注意：

- 用 CAM 程序组/工序名包含**同名**对象，检验路由层是否会串（`my_group_level_map`、`my_group_has_direct_ops` 等数组以 name 为 key）。如存在同名风险，参考 P2 中的"层级缓存多 key（name + tag + path）"方案。
- 用包含**中文、空格、特殊字符**的部件名，检验输出目录名与 NC 文件名是否被 `PB_CMD_sanitize_file_component` 正确清理。

## P2 / P3 后续优化参考

- 层级缓存多 key（name + tag + path）：修改 `_write_hierarchy_cache()`（Python）与 `PB_CMD_user_load_cam_hierarchy_cache`（Tcl），引入 `nx_cam_tag(name)` / `nx_cam_name(tag)` 数组；Tcl 端 `my_group_level_map` 改为 tag 作 key。改动面大，建议稳定期后再做。
- 完整 14 变量配置集中化：遗留变量（`my_smart_route_debug`、`my_output_operation_separator`、`my_cleanup_delay_ms`、`my_include_date_in_header` 等）目前仍分散，可按 PR3 保守模式逐步委托给 helper。
