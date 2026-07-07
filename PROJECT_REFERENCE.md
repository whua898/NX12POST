# NX12POST 项目文件备忘

> 最后更新：2026-07-07
> 用途：快速定位各 .tcl 后处理文件的差异、已知问题、修复记录

---

## 1. 文件清单与定位

| 文件 | 行数 | 定位 | 当前状态 |
|------|------|------|----------|
| `new_post.tcl` | 5150 | 主力后处理（无刀库三轴铣，多级组分目录输出） | 生产使用中 |
| `new_post.def` | ~960 | 地址/格式/模板定义 | 生产使用中 |
| `new_post.pui` | — | Post Builder 配置 | 生产使用中 |
| `new_post_user.tcl` | ~17 | 用户扩展（仅 MOM_end_of_group 占位） | 生产使用中 |
| `mill3ax.tcl` | 3777 | 简单三轴铣（英制，无智能分文件） | 备用/参考 |
| `mill3ax.def` | — | 对应 DEF | 备用 |
| `mill3ax.pui` | — | 对应 PUI | 备用 |
| `wv.tcl` | 4211 | GZJ 定制版（公制，含机床事件占位） | 备用/参考 |
| `wv.def` / `wv.pui` | — | 对应 | 备用 |
| `ugpost_base.tcl` | 数千 | NX 平台基础库（所有后处理初始化时 source） | 只读 |
| `Original/` | — | 原始模板备份（new_post.tcl/def/pui） | 参考基线 |
| `nc/` | — | 后处理实际输出目录 | 生产输出 |

---

## 2. 三个 .tcl 核心差异

### 2.1 关键变量对照

| 变量 | new_post | mill3ax | wv |
|------|----------|---------|-----|
| `mom_sys_list_output` | **ON**（硬编码） | OFF | OFF |
| `mom_sys_output_file_suffix` | nc | nc | **NC**（大写） |
| `mom_kin_output_unit` | MM | **IN**（英制） | MM |
| 智能分文件 | ✅ | ❌ | ❌ |
| Hook MOM_start_of_path | ✅ | ❌ | ❌ |
| 白名单 my_valid_files | ✅ | ❌ | ❌ |
| 刀具指纹校验 | ✅ | ❌ | ❌ |

### 2.2 new_post 独有机制

- **`PB_CMD_init_smart_grouping`**：在 `PB_start_of_program` → `PB_CMD_kin_start_of_program` 链中调用
  - `rename MOM_start_of_path MOM_start_of_path_orig` → 挂自定义拦截器
  - `rename MOM_start_of_group MOM_start_of_group_orig` → 维护 `my_group_level_map` + `my_group_stack`
  - `rename MOM_end_of_group MOM_end_of_group_orig` → 维护组栈弹出
- **`PB_CMD_smart_file_switch`**：在 `MOM_start_of_path` 拦截器里调用
  - Level 0：根目录工序 → 不建文件夹
  - Level 1：一级组下工序 → 文件夹=一级组名，文件名=工序名
  - Level 2：二级组下工序 → 文件夹=一级组名，文件名=二级组名（合并输出）
  - 附带：刀具指纹校验（`SUB_GROUP_BASE_TOOL_FINGERPRINT`）
- **`my_valid_files` 白名单**：只有 `PB_CMD_smart_file_switch` 路由生成的文件才入白名单
- **`PB_CMD_cleanup_smart_grouping`**：在 `MOM_end_of_program` 里关闭 ptp、恢复原始文件名
- **`PB_CMD_123`**：输出 operation_time / machine_time（调用 def 里的 `machine_time_info` / `operation_time_info` 模板）

### 2.3 mill3ax 特征

- 简单直接，无 Hook、无分文件
- 刀具调用：`PB_auto_tool_change` → `tool_change` → `tool_change_1` → `tool_change_2`
- `PB_CMD_fix_RAPID_SET` 在 `PB_start_of_program` 调用
- RAPID_SET 用 `mom_current_motion` 字符串匹配（`initial_move`/`first_move`）

### 2.4 wv 特征

- 公制，输出 .NC 大写后缀
- 多出大量 UDE 事件占位：`MOM_insert`、`MOM_operator_message`、`MOM_opskip_*`、`MOM_pprint`、`MOM_text`
- 多出机床事件：`MOM_clamp`、`MOM_head`/`MOM_Head`/`MOM_HEAD`、`MOM_rotate`、`MOM_lock_axis`、`MOM_origin`、`MOM_power`、`MOM_workpiece_*`、`MOM_select_head`、`MOM_set_polar`、`MOM_set_axis`、`MOM_zero`
- `PB_start_of_program` 额外调用 `PB_CMD_tool_massge`
- UDE handler 用 `PB_CMD_MOM_*` 间接调用，原始事件被 rename 为 `ugpost_MOM_*`

---

## 3. 已修复的问题（2026-07-07）

### 3.1 def 模板 `^` 错误引用 → 1745007

**位置**：`new_post.def` 第 724-728、734-738 行

**错误**：
```tcl
Text[TOTAL MACHINE TIME: ]
Text[^mom_my_machine_time]   ← 错：^ 是"强制输出地址"前缀
Text[ MINUTES]
```

**修复**：恢复为单行 `$` 引用（与 `Original/new_post.def` 一致）：
```tcl
Text[(TOTAL MACHINE TIME: $mom_my_machine_time MINUTES)]
Text[(OPERATION TIME: $mom_my_op_time MINUTES)]
```

**根因**：NX block template 里 `^` 是强制输出地址前缀，后面必须跟合法地址字符。`^mom_my_machine_time` 让 Turbo Expression 解析器报 `Invalid Turbo Expression`。

### 3.2 `MOM_do_template initial_move` → 1745006

**位置**：`new_post.tcl` 第 4109 行（PB_CMD_smart_file_switch 文件初始化包内）

**错误**：`catch { MOM_do_template initial_move }`

**修复**：删除该行。def 里没有 `initial_move` 模板，初始移动由 `MOM_initial_move` 事件处理。

### 3.3 `mom_sys_dialog_list_output` 不存在 → 1770002

**位置**：`new_post.tcl` MOM_end_of_program 里加的诊断代码

**错误**：直接访问 `$mom_sys_dialog_list_output`，变量不存在

**修复**：诊断代码改用 `info exists` 保护；最终移除整个 NC 代码清单输出功能（用户决定不做了）

---

## 4. NX 后处理机制备忘

### 4.1 .tcl 加载与缓存

- NX 在 Post Builder 加载 .pui 时编译 .tcl 到内存
- 后处理执行时调用内存中的编译版本
- **修改 .tcl 后必须重启 NX 才能生效**（部分版本可关闭部件重开，但重启最可靠）
- 严格说不是"缓存"，是"内存中的编译版本未刷新"

### 4.2 "列出输出" 对话框

- 对应变量：`mom_sys_list_output`（控制 .lpt 文件生成）
- 对话框复选框控制的是弹窗显示，与 `mom_sys_list_output` 是**两个不同机制**
- 勾选 → NX 弹窗显示 listing 内容；不勾 → 不弹窗
- `MOM_output_to_listing_device` 输出到 listing 设备（.lpt 文件）

### 4.3 常见错误码

| 错误码 | 含义 | 典型原因 |
|--------|------|----------|
| 1745006 | Invalid block template name | `MOM_do_template` 引用了不存在的模板 |
| 1745007 | Invalid expression in block template | def 里 `Text[]` 语法错（如 `^变量名`） |
| 1770002 | TCL interpreter error（通用包装） | 任何 TCL 错误最终被包装成此码 |

### 4.4 调试技巧

- 看 `F:\TEMP\wh898*.syslog` 找真正的 TCL 错误（1770002 前的 `+++` 行）
- 看 `.lpt` listing 文件确认后处理实际输出
- 在 .tcl 里加 `MOM_output_to_listing_device "DEBUG: ..."` 输出到 listing
- 所有 `catch` 包裹的代码出错不会中断，但错误仍会记录到 syslog

---

## 5. 项目目录结构

```
NX12POST/
├── new_post.tcl          ← 主力
├── new_post.def
├── new_post.pui
├── new_post_user.tcl
├── mill3ax.tcl           ← 备用
├── mill3ax.def
├── mill3ax.pui
├── wv.tcl                ← 备用
├── wv.def
├── wv.pui
├── ugpost_base.tcl       ← NX 基础库
├── wv.cdl                ← 刀具库
├── Original/             ← 原始备份
│   ├── new_post.tcl
│   ├── new_post.def
│   └── new_post.pui
├── nc/                   ← 输出目录
│   ├── 正面/TOP-*.nc
│   ├── 左端面/LEF-*.nc
│   ├── 右端面/RIG-*.nc
│   ├── 前端面/FRO-*.nc
│   ├── BLA/BLA-*.nc
│   └── BOT/BOT-*.nc
├── ColumnConfigurations/ ← 列配置
├── .git/
└── README.md
```

---

## 6. 业务背景

- **机床类型**：无刀库三轴数控铣床
- **核心需求**：多级程序组自动分目录输出
  - 一级组（TOP/RIG/LEF/FRO/BLA/BOT）→ 生成文件夹
  - 二级组（如 TOP-03）→ 组合并输出为单一 .nc
  - 独立工序 → 单独 .nc
- **附加功能**：刀具指纹校验、白名单防流氓文件、Post Builder 防覆盖
- **CAM 环境**：Siemens NX 12.0.2.9
