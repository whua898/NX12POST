# Post Builder 操作说明

本文档说明在 NX 12 Post Builder 中打开并保存 `smart_post.pui` 时，哪些自定义命令必须保留、如何检查，以及哪些代码不要在 PB 里随意移动。

## 文件对应关系

- Prism 工作文件：`smart_post.tcl.tex`、`smart_post.pui.tex`、`smart_post.def.tex`、`smart_post_user.tcl.tex`
- 给 NX/Post Builder 使用时，对应去掉 `.tex` 后缀：`smart_post.tcl`、`smart_post.pui`、`smart_post.def`、`smart_post_user.tcl`
- 稳定参考基线：`1111.tex`，只用于对照，不要修改。
- 本次修改前已备份到：`backup_20260708_030939/`

## 总原则

- 不要在 PB 保存后手写修改 `PB_start_of_program`、`MOM_end_of_program` 这类标准事件过程。
- 智能分组 Hook 的初始化入口放在 PB 界面可见的 `Program Start Sequence` 中，使用自定义命令 `PB_CMD_init_smart_grouping`。
- 程序尾和清理逻辑保留在 PB 的 `Program End Sequence`，这样 PB 保存后仍能同步生成。
- 不要改 `PB_CMD_before_output`、`my_original_ptp_chan`、原始汇总 NC 预览文件链路。

## PB 中必须检查的位置

### 1. Program Start Sequence

位置：`Program & Tool Path` → `Program` → `Program Start Sequence`

推荐顺序如下：

```text
PB_CMD_init_smart_grouping
MOM_set_seq_off
rewind_stop_code
PB_CMD_program_header
start_of_program
start_of_program_highspeed
PB_CMD_init_helix
```

注意：

- `PB_CMD_init_smart_grouping` 必须放在最前面，先挂载 `MOM_start_of_group` / `MOM_start_of_path` 拦截器。
- 如果 PB 保存后丢失这一项，请在这个序列里重新添加。
- 不需要在标准事件 Tcl 过程 `PB_start_of_program` 里手写添加；通过 PB 序列添加即可。

### 2. Custom Command：PB_CMD_init_smart_grouping

位置：`Program & Tool Path` → `Custom Command` → 找到 `PB_CMD_init_smart_grouping`

必须确认这个自定义命令存在。它内部负责挂载：

```text
MOM_start_of_group
MOM_end_of_group
MOM_start_of_path
```

要求：

- 不要把这段 Hook 逻辑拆到 `PB_start_of_program` 或 `MOM_end_of_program` 标准事件里。
- 不要删除 `rename MOM_start_of_path MOM_start_of_path_orig` 这类 Hook 保护逻辑。
- 如果 PB 界面中看不到 `PB_CMD_kin_start_of_program`，这是可以接受的；不需要找它，也不需要改它。

### 3. Program End Sequence

位置：`Program & Tool Path` → `Program` → `Program End Sequence`

推荐顺序如下：

```text
PB_CMD_123
MOM_set_seq_off
PB_CMD_custom_program_footer
rewind_stop_code
PB_CMD_cleanup_smart_grouping
PB_CMD_SUB_GROUP_BASE_TOOL_FINGERPRINT
```

关键顺序说明：

- `PB_CMD_custom_program_footer` 必须在 `PB_CMD_cleanup_smart_grouping` 之前，用于给最后一个真实 NC 文件补程序尾。
- `PB_CMD_cleanup_smart_grouping` 必须在 `CLOSE_files` 之前执行；PB 生成的 `MOM_end_of_program` 会在 Program End Sequence 后调用 `LIST_FILE_TRAILER` 和 `CLOSE_files`。
- `PB_CMD_SUB_GROUP_BASE_TOOL_FINGERPRINT` 用于结束阶段刀具指纹状态处理，保留在清理后。

### 4. Custom Command：PB_CMD_before_output

位置：`Program & Tool Path` → `Custom Command` → 找到 `PB_CMD_before_output`

必须保留核心逻辑：

```tcl
global mom_o_buffer my_original_ptp_chan
if { [info exists my_original_ptp_chan] && $my_original_ptp_chan != "" } {
   catch { puts $my_original_ptp_chan $mom_o_buffer }
   catch { flush $my_original_ptp_chan }
}
```

注意：

- 不要在此命令中调用 `MOM_output_literal`、`MOM_do_template` 等输出命令。
- 这个命令只负责镜像 `mom_o_buffer` 到临时汇总 NC，保证 NX “列出输出”窗口能显示 NC 代码。

## PB 保存后的自检

保存 `.pui` 后，用文本搜索确认以下内容。

### 必须存在

```text
PB_CMD_init_smart_grouping
PB_CMD_custom_program_footer
PB_CMD_cleanup_smart_grouping
PB_CMD_before_output
my_original_ptp_chan
puts $my_original_ptp_chan $mom_o_buffer
```

### 不应出现

```text
PB_CMD_output_combined_nc_preview
```

### 需要重点看

- `Program Start Sequence` 应包含 `PB_CMD_init_smart_grouping`，并放在第一项。
- 如果文本里还有 `PB_CMD_kin_start_of_program`，不用在 PB 界面找它；它可能是 PB/NX 内部生成或隐藏的初始化命令。
- `Program End Sequence` 应包含 `PB_CMD_custom_program_footer` 和 `PB_CMD_cleanup_smart_grouping`。
- 不要出现“仅当 `mom_sys_list_output == ON` 才打开或维护 `my_original_ptp_chan`”的逻辑。

## 修改后测试步骤

1. 关闭并重启 NX，避免 NX 继续使用内存中的旧 Tcl。
2. 用 `smart_post.pui` 打开 PB，按上面三处检查 Start、End、Custom Command。
3. 保存 PB。
4. 用 NC_PROGRAM 测试后处理，确认输出类似：

```text
NC/TOP/TOP-01_D63R08L200.nc
NC/TOP/TOP-02_D63R08L200.nc
NC/TOP/TOP-03_中心钻.nc
```

5. 勾选“列出输出”测试一次，确认信息窗口有 NC 代码。
6. 不勾选“列出输出”测试一次，确认临时汇总 NC 短暂出现后被后台清理。
7. 如果临时文件未清理，查看 `%TEMP%/nx_cleanup_latest.log`。
8. 日志里应看到 `.nc`、`.ptp`、`.lpt` 目标；如果只看到 `.lpt`，说明临时汇总 NC 没有进入清理列表。
9. 如果 `.nc/.ptp` 显示 `DELETED_OR_NOT_EXIST`，但 `.lpt` 显示 `FAILED_LOCKED_OR_IN_USE`，说明 NX 仍占用 listing 报告文件；这不影响真实 NC 拆分输出和临时汇总 NC 清理。

## 禁止操作

- 不要修改 `1111.tex`。
- 不要修改 `ugpost_base.tcl`。
- 不要删除 `PB_CMD_before_output`。
- 不要删除或禁用 `my_original_ptp_chan`。
- 不要把临时汇总 NC 当成 bug 文件禁止生成。
- 不要为了减少临时文件而把预览链路改成只在“列出输出”打开时执行。