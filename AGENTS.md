# NX12 Smart Post Agent Rules

本目录是 Siemens NX 12 智能后处理项目。修改这里的文件时，优先保证 NX12/Tcl 兼容性、后处理输出稳定性，以及文档与最终实现一致。

## 必守原则

- 修改前先阅读相关上下文，禁止凭印象改 Tcl/Python 逻辑。
- 默认只修改当前工作区内文件，不创建虚拟环境，不安装依赖。
- `1111.tcl`、`Original/` 视为稳定基线/备份，除非用户明确要求，不要修改。
- `ugpost_base.tcl` 只读参考，不要修改。
- 当前正式后处理器是 `smart_post.tcl` / `smart_post.tcl.tex`，核心自动调用脚本是 `NX_Smart_Post/application/get_cam_hierarchy_and_post.py`。
- Tcl 改动必须考虑 NX12 老 Tcl 兼容性，避免使用过新的 Tcl 命令；优先使用 `catch`、`info exists`、`info commands` 做防御。
- 不要破坏原始汇总 NC 预览链路：`my_original_ptp_file_name`、`my_original_ptp_chan`、`PB_CMD_before_output` 镜像写入是 NX “列出输出/信息窗口”显示 NC 代码的关键。

## 最终实现概要

项目由两个脚本配合实现：

- `get_cam_hierarchy_and_post.py`
  - 在 NX Journal 中执行。
  - 导出 CAM 程序组层级缓存 `nx_cam_hierarchy.tcl`。
  - 读取当前选中 CAM 对象；无选择时回退到顶层程序根。
  - 默认调用 `DEFAULT_POST_NAME = "smart_post"`，可用环境变量 `NX_SMART_POST_NAME` 覆盖。
  - 设置 `NX_SMART_POST_USE_CACHE=1`，让 Tcl 后处理器只在本次自动运行中使用刚生成的层级缓存。
  - 设置 `NX_SMART_POST_PART_NAME` 和 `NX_SMART_POST_PART_NAME_UTF8_HEX`，辅助 Tcl 端生成“部件名”总输出目录。
  - 自动批量后处理多个根对象时设置 `NX_SMART_POST_BATCH_INDEX` / `NX_SMART_POST_BATCH_TOTAL`，Tcl 端只在最后一次打开输出目录。

- `smart_post.tcl.tex`
  - 使用 Hook/rename 接管关键事件，同时保留原生事件逻辑。
  - 通过缓存或 MOM 组事件维护程序组栈，按 CAM 层级路由输出文件。
  - 输出总目录固定为：`部件所在目录/部件名/`。
  - 支持多层管理组：管理组作为目录层级保留，最终 NC 文件仍按实际加工组/工序生成。
  - 二级加工组合并为单个 `.nc`，并用刀具指纹防止无刀库机床混入不同刀具。
  - 后处理结束后打开/聚焦输出总目录，并带批量/短时间去重。
  - 后台延迟清理临时汇总 `.nc`、同名 `.ptp` 和 `.lpt`。

## 输出规则

- 选中 `NC_PROGRAM`：一级组生成目录；一级组下独立工序单独输出；二级组输出单一合并 NC。
- 选中一级组：只输出该一级组下的独立工序和二级组合并文件。
- 选中工序：输出到所属一级组目录，文件名为工序名。
- 选中二级组：输出到所属一级组目录，文件名为二级组名，组内工序合并。
- 不要默认生成“每个一级程序组一个总合并 NC 文件”。

示例：

```text
部件名/
├── TOP/
│   ├── TOP-01.nc
│   ├── TOP-02.nc
│   └── TOP-03.nc
└── LEFT/
    ├── LEFT-01.nc
    └── LEFT-02.nc
```

## 关键输出链路禁区

不要为了减少临时文件而禁止原始汇总 NC 的生成。NX 信息窗口显示 NC 代码依赖主 `ptp_file_name` 对应输出流，而不是单纯依赖 `.lpt`。

必须保持：

- 原始汇总 NC/预览文件短暂存在。
- `PB_CMD_before_output` 将 `mom_o_buffer` 写入 `my_original_ptp_chan`。
- `CLOSE_files` 或清理逻辑延迟删除临时汇总 `.nc`、同名 `.ptp`、`.lpt`。

高风险误改：

- 删除或禁用 `my_original_ptp_chan`。
- 让 `PB_CMD_before_output` 不再镜像 `mom_o_buffer`。
- 把原始汇总 NC 维护逻辑改成“只有勾选列出输出才执行”。
- 用写 `.lpt`、`LIST_FILE_TRAILER` 或 `MOM_output_to_listing_device` 替代主 NC 预览链路。

## 清理与打开目录

- 勾选“列出输出”：临时文件默认至少延迟 `10000 ms` 清理。
- 未勾选“列出输出”：临时文件默认延迟 `1000 ms` 清理。
- 可通过 Tcl 全局变量 `my_cleanup_delay_ms` 覆盖延迟。
- Windows 使用 `wscript.exe //B //Nologo` 启动隐藏 `.vbs`，再由 `.cmd` 执行重试删除，避免 cmd 窗口闪现。
- 清理日志：`%TEMP%/nx_cleanup_latest.log`。
- 自动批量后处理时按 `NX_SMART_POST_BATCH_INDEX/TOTAL` 只在最后打开输出目录。
- 原生 NX 后处理不带批量变量时，使用 `NX_SMART_POST_OPENED_OUTPUT_DIR` 和 `NX_SMART_POST_OPENED_OUTPUT_TIME_MS` 做短时间去重。

## 调试与验证

- 智能路由 debug 默认关闭；排障时设置 Tcl 全局变量 `my_smart_route_debug=1` 或环境变量 `NX_SMART_ROUTE_DEBUG=1`。
- Python 修改后至少运行：

```bash
python -m py_compile NX12POST/NX_Smart_Post/application/get_cam_hierarchy_and_post.py
```

- LaTeX 文档修改后可运行：

```bash
pdflatex main.tex
```

- Tcl 逻辑最终必须在 NX12 实机中验证，重点覆盖：选中 `NC_PROGRAM`、一级组、二级组、单工序、多层管理组、勾选/不勾选“列出输出”。

## 常见故障判断

- “列出输出”没有 NC 代码：优先检查 `my_original_ptp_chan` 和 `PB_CMD_before_output` 镜像链路。
- 临时 `部件名.nc/.ptp/.lpt` 短暂出现：正常，是 NX 主输出预览链路的一部分，随后后台清理。
- 清理失败：查看 `%TEMP%/nx_cleanup_latest.log`；有 `FAILED_LOCKED_OR_IN_USE` 通常表示 NX 或杀软仍占用文件。
- 修改 `.tcl` 不生效：NX 可能缓存了后处理 Tcl，建议重启 NX 后复测。
