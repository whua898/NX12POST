# NX12 智能后处理器说明

本项目用于 Siemens NX 12.0.2.9 三轴铣后处理，目标机床为**无刀库机床**。核心能力是按 NX CAM 程序组层级自动分目录、拆分/合并 NC 文件，并保留 NX “列出输出”窗口中的 NC 代码显示。

## 当前结论

- 当前正式工作版：`new_post.tcl`
- 稳定参考基线：`1111.tcl`，不要修改，仅作回退和对照
- `new_post.tcl` 当前基于 `1111.tcl` 的稳定 NC 显示机制，只优化了清理时机和隐藏清理启动
- 不要再改 `my_original_ptp_chan`、`PB_CMD_before_output`、原始汇总 NC 这条链路

## 核心需求

### 选中 `NC_PROGRAM`

- 一级组，例如 `TOP`、`RIGHT`、`LEFT` → 生成文件夹
- 一级组下独立工序，例如 `TOP-01` → 输出 `TOP/TOP-01.nc`
- 二级组，例如 `TOP-03` → 输出 `TOP/TOP-03.nc`，包含组内所有子工序，且只有单一程序头和程序尾

### 选中一级程序组

```text
选中 TOP → 输出：
TOP/TOP-01.nc
TOP/TOP-02.nc
TOP/TOP-03.nc
```

### 选中工序或二级组

```text
选中 TOP-01 → TOP/TOP-01.nc
选中 TOP-03 → TOP/TOP-03.nc
```

注意：不要默认生成“每个一级程序组一个合并 NC 文件”。

## 关键文件

| 文件 | 作用 |
|---|---|
| `new_post.tcl` | 当前正式工作版，核心逻辑在这里维护 |
| `1111.tcl` | 稳定参考基线，曾验证“列出输出”能正常显示 NC 代码 |
| `new_post.def` | Post Builder DEF 模板 |
| `new_post.pui` | Post Builder 配置 |
| `new_post_user.tcl` | 用户扩展入口 |
| `ugpost_base.tcl` | NX 后处理基础库，只读参考，不建议改 |
| `Original/` | 原始备份目录 |
| `nc/` | NC 输出目录 |

## 核心机制

### Hook 注入

通过 `rename` 挂载拦截器，避免直接重写标准事件导致 Post Builder 覆盖：

```tcl
rename MOM_start_of_path MOM_start_of_path_orig
proc MOM_start_of_path { } {
    catch { PB_CMD_smart_file_switch }
    catch { MOM_start_of_path_orig }
}
```

### 程序组层级

- `MOM_start_of_group` 拦截器维护 `my_group_level_map` 和 `my_group_stack`
- `PB_CMD_smart_file_switch` 根据当前工序所在层级决定目标文件夹和文件名
- `my_valid_files` 记录由智能路由生成的合法 NC 文件，避免误删

### 文件切换

- Level 0：根目录工序 → 输出到根目录，文件名为工序名
- Level 1：一级组下工序 → 文件夹为一级组名，文件名为工序名
- Level 2：二级组下工序 → 文件夹为一级组名，文件名为二级组名，组内工序合并

### 刀具安全

无刀库机床使用刀具指纹校验，避免二级组合并时混入不同刀具：

```tcl
刀具名称 | 刀具类型 | 直径 | 下半径/鼻圆角 | 总长
```

相关变量：`SUB_GROUP_BASE_TOOL_FINGERPRINT`。

## “列出输出”与临时汇总 NC

结论：NX “列出输出”不是简单显示 `.lpt`。它主要依赖主 `ptp_file_name` 对应的 NC 输出文件；`.lpt` 是 listing/commentary 文件，不是信息窗口 NC 代码的根来源。

### `ugpost_base.tcl` 机制

- `OPEN_files` 根据 `mom_output_file_basename` 生成主输出文件：`ptp_file_name = basename + output_extn`，并在 `mom_sys_ptp_output == "ON"` 时用 `MOM_open_output_file` 打开它。参考：`ugpost_base.tcl:1861`、`ugpost_base.tcl:1908`
- `.lpt` 文件名是 `lpt_file_name = basename + list_extn`，只在 `mom_sys_list_output == "ON"` 时打开。参考：`ugpost_base.tcl:1862`、`ugpost_base.tcl:1921`
- 每次 NC 输出前，`MOM_before_output` 调 `LIST_FILE`；`LIST_FILE` 只是把当前 `mom_o_buffer` 加 commentary 写入 `.lpt`。参考：`ugpost_base.tcl:2093`
- `LIST_FILE_TRAILER` 写的是机床时间、长度、刀具清单等 listing 尾部，不决定 NC 信息窗口显示哪份 NC。参考：`ugpost_base.tcl:2336`
- `CLOSE_files` 只关闭 `list_file/warn_file` 并删除空 `.lpt/.out`，没有把 `.lpt` 推到信息窗口。参考：`ugpost_base.tcl:2042`

### Post Builder 文档机制

- `Listing File tab` 说明 listing file 包含 header、NC file、warnings、absolute axis positions。
- Listing 文件名跟 NC 输出文件同名，只是扩展名换成 listing 扩展，例如 `1234.ptp -> 1234.lpt`。
- 这说明 `.lpt` 是“随主 NC 文件派生的报告文件”，不是 NX 最终显示 NC 代码的主输出流。

### 本项目判断

`1111.tcl` 正常，是因为它始终保留/维护原始主输出文件，例如 `L型安装板_stp.nc`，并通过 `PB_CMD_before_output` 把每行 `mom_o_buffer` 镜像写进去。参考：`1111.tcl:4048`、`1111.tcl:5289`

曾经的问题版为了“不勾选列出输出时不要生成 `L型安装板_stp.nc`”，把主输出文件维护逻辑改成只在 `mom_sys_list_output == ON` 时执行。这样会切断 NX 信息窗口能读取的“原始主 NC 文件”。后来尝试写 `.lpt`、写 `list_file`、在 `LIST_FILE_TRAILER` 前追加都不稳定，因为方向错了：要恢复的是主 `ptp_file_name` 对应 NC 文件，而不是 `.lpt`。

### 正确修复方向

- 不依赖 `.lpt` 显示 NC。
- 恢复 `1111.tcl` 的核心机制：始终让原始 `my_original_ptp_file_name` 作为临时汇总 NC 存在，并用 `PB_CMD_before_output` 镜像写入。
- 为解决“未勾选列出输出也生成 `L型安装板_stp.nc`”问题，不阻止它生成；而是让它作为 NX 主输出预览临时文件生成，然后延迟清理。
- `L型安装板_stp.nc` 不是 bug 文件，它是 NX 信息窗口绑定需要的“主输出占位/预览文件”。真正要优化的是清理策略和清理时机，而不是禁止生成。

因此当前版本保留 `1111.tcl` 的稳定机制：

- 原始输出文件，例如 `L型安装板_stp.nc`，作为临时汇总 NC/预览文件存在
- `PB_CMD_before_output` 将每行 `mom_o_buffer` 镜像写入 `my_original_ptp_chan`
- NX 信息窗口能读取这个临时汇总 NC 并显示代码
- 后处理结束后后台清理该临时汇总 NC、对应 `.ptp` 和 `.lpt`

不要为了“未勾选列出输出时不生成临时汇总 NC”而禁用这条链路，否则会再次导致信息窗口没有 NC 代码。

## 清理策略

当前清理策略只优化时机和启动方式，不改变输出链路：

- 勾选“列出输出”：默认等待 `10000 ms`，确保 NX 有足够时间读取临时汇总 NC
- 未勾选“列出输出”：默认等待 `1000 ms`，尽量减少临时文件可见时间
- 可通过预设 `my_cleanup_delay_ms` 手动覆盖
- Windows 下通过 `wscript.exe //B //Nologo` 隐藏启动清理脚本，避免 `cmd` 窗口闪现
- 清理日志：`%TEMP%/nx_cleanup_latest.log`

日志中常见成功结果：

```text
After delay ...
Target: ...L型安装板_stp.nc
DELETED_OR_NOT_EXIST: ...L型安装板_stp.nc
```


## 2026-07-08 排障经验教训

### 1. 先判清楚 NX 输出链路，不要误把 `.lpt` 当主 NC 来源

今天反复验证后确认：NX “列出输出/信息窗口”显示 NC 代码时，关键依赖的是主 `ptp_file_name` 对应的 NC 输出流；`.lpt` 是 listing/commentary 报告文件，只能记录列表信息，不能替代主 NC 输出通道。

错误方向包括：

- 只向 `.lpt` 写 NC 代码
- 在 `LIST_FILE_TRAILER` 前向 `list_file` 追加 NC
- 用 `MOM_output_to_listing_device` 试图恢复 NC 显示

这些方式都不是根因修复。正确方向是保留原始汇总 NC 预览文件，并持续镜像 `mom_o_buffer`。

### 2. `1111.tcl` 是本轮最重要的可工作基线

`1111.tcl` 已验证能正常显示 NC 代码。它的关键机制是：

- 原始输出文件（如 `L型安装板_stp.nc`）作为临时汇总 NC 存在
- `my_original_ptp_chan` 以 append 方式打开该文件
- `PB_CMD_before_output` 每次输出前把 `mom_o_buffer` 写入该文件
- 结束后再延迟清理临时 `.nc/.ptp/.lpt`

后续任何修复如果破坏这条链路，都必须视为高风险。

### 3. “未勾选列出输出也生成临时汇总 NC”不是 bug

这个临时汇总 NC 是 NX 主输出/预览链路的一部分。之前为了避免未勾选时生成 `L型安装板_stp.nc`，把原始汇总 NC 的维护逻辑限制为“仅勾选列出输出时才执行”，结果直接导致“列出输出”窗口没有 NC 代码。

正确处理方式：

- 允许临时汇总 NC 短暂生成
- 不改输出链路
- 只优化后台清理时机和清理方式

当前策略：未勾选时约 `1s` 后清理；勾选时保守等待 `10s`。

### 4. 清理脚本窗口闪现的根因是 `cmd.exe /c start`

`cmd.exe /c start "" /min cmd.exe /c ...` 即使带 `/min`，Windows 仍可能闪一下窗口。已改为：

- 生成临时 `.cmd` 执行实际删除
- 生成临时 `.vbs` 通过 `WScript.Shell.Run ..., 0, False` 隐藏启动 `.cmd`
- 用 `wscript.exe //B //Nologo` 启动 `.vbs`

实际日志已验证：不再闪窗，且清理成功。

### 5. 修改时必须基于正确版本，避免把问题版继续修下去

本轮曾出现一次误操作：在“问题版”上继续改隐藏清理，导致又回到“没有 NC 代码输出”。后续必须遵守：

- 涉及 NC 显示问题时，先对照 `1111.tcl`
- 确认当前文件没有 `PB_CMD_output_combined_nc_preview`
- 确认当前文件没有“仅在勾选列出输出时才维护原始组合输出文件”的逻辑
- 确认 `PB_CMD_before_output` 仍写入 `my_original_ptp_chan`

### 6. 日志判断方法

清理日志路径：`%TEMP%/nx_cleanup_latest.log`。

成功样例：

```text
After delay ...
Target: ...L型安装板_stp.nc
DELETED_OR_NOT_EXIST: ...L型安装板_stp.nc
```

判断方式：

- 有 `Scheduled cleanup script` 但没有 `After delay`：隐藏启动器或系统策略问题
- 有 `After delay` 但 `FAILED`：文件仍被 NX/杀软占用
- 有 `DELETED_OR_NOT_EXIST`：清理成功或目标已不存在

## 输出示例

```text
NC/
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

## 常见问题

### “列出输出”没有 NC 代码

优先检查：

- 是否误删/禁用了 `my_original_ptp_chan`
- `PB_CMD_before_output` 是否还在写：`puts $my_original_ptp_chan $mom_o_buffer`
- 是否出现了 `PB_CMD_output_combined_nc_preview` 或“仅在勾选列出输出时才维护原始组合输出文件”的旧问题逻辑

### 未勾选“列出输出”仍短暂生成 `L型安装板_stp.nc`

这是正常行为。该文件是 NX 主输出预览临时文件，当前会在约 `1s` 后后台清理。

### 清理文件没有删除

查看：`%TEMP%/nx_cleanup_latest.log`。

- 有 `Scheduled cleanup script` 但没有 `After delay`：清理脚本没有启动或被系统策略拦截
- 有 `After delay` 但显示 `FAILED`：文件仍被 NX 或杀软占用
- 显示 `DELETED_OR_NOT_EXIST`：清理成功或文件已经不存在

### 修改后 NX 没生效

NX 会加载/编译后处理 Tcl 到内存。修改 `.tcl` 后，建议重启 NX 再测试。

## 常见错误码

| 错误码 | 含义 | 典型原因 |
|---|---|---|
| `1745006` | Invalid block template name | `MOM_do_template` 调用了不存在的模板 |
| `1745007` | Invalid expression in block template | DEF 中 `Text[]` 表达式错误，例如误用 `^变量名` |
| `1770002` | Tcl interpreter error | Tcl 运行错误的通用包装 |

## 开发注意事项

- 不要直接修改 `1111.tcl`
- 不要修改 `ugpost_base.tcl`，只读参考即可
- 尽量在 `new_post.tcl` 中维护自定义逻辑
- Post Builder 可能覆盖标准事件入口，复杂逻辑应放在自定义命令或 Hook 安全区
- 所有访问 NX 变量的逻辑尽量使用 `info exists` 和 `catch` 防御
- 路径比较前使用 `file normalize` / `file nativename`，减少 Windows 路径差异问题

## 已知修复记录

- 修复 DEF 模板中 `^mom_my_machine_time` / `^mom_my_op_time` 导致的 `1745007`
- 删除不存在的 `MOM_do_template initial_move` 调用，避免 `1745006`
- 移除访问不存在变量 `mom_sys_dialog_list_output` 的诊断逻辑，避免 `1770002`
- 恢复 `1111.tcl` 的 NC 显示机制，解决“列出输出”无 NC 代码
- 清理启动从 `cmd.exe /c start` 改为 `wscript` 隐藏启动，解决窗口闪现
- 未勾选“列出输出”时清理延迟调为 `1000 ms`