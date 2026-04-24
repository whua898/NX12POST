# NX12 后处理程序 - 多级程序组自动分目录输出

## 📋 项目概述

这是一个为**无刀库机床**开发的智能 UG NX12 后处理器，实现了多级程序组的自动化文件输出管理。

### 核心特性
- ✅ **自动分目录**：一级程序组名作为文件夹名
- ✅ **智能合并**：二级程序组内所有工序合并为一个 NC 文件
- ✅ **刀具一致性检查**：防止无刀库机床换刀错误
- ✅ **无损 Hook 机制**：使用 TCL rename 防止 PB 覆盖
- ✅ **流氓文件清理**：自动删除不在白名单中的临时文件

## 🎯 三大核心需求

### 1. 选中 NC_PROGRAM 时
- 一级组（如 `TOP`）→ 生成文件夹 `TOP/`
- 独立工序（如 `TOP-01`）→ 生成单独 NC 文件 `TOP/TOP-01.nc`
- 二级组（如 `TOP-03`）→ 生成单一 NC 文件 `TOP/TOP-03.nc`（包含其下所有子工序，单一程序头和尾）

### 2. 选中单个或多个一级程序组时
```
选中 TOP → 输出：
  TOP/TOP-01.nc
  TOP/TOP-02.nc
  TOP/TOP-03.nc
```

### 3. 选中工序或二级组时
```
选中 TOP-01（工序）→ 输出：TOP/TOP-01.nc
选中 TOP-03（二级组）→ 输出：TOP/TOP-03.nc（包含子工序，单一程序头、尾）
```

**注意**：不会默认生成每个一级程序组合并的 NC 文件。

## 🏗️ 技术架构与核心逻辑

### 1. 无损注入与防覆盖 (Hooking/AOP)

为防止 UG 后处理构造器覆盖自定义代码，使用 TCL 的 `rename` 机制挂载拦截器：

```tcl
# 在 PB_CMD_init_smart_grouping 中执行
rename MOM_start_of_path MOM_start_of_path_orig
proc MOM_start_of_path { }
    # 自定义逻辑
    PB_CMD_smart_file_switch
    # 调用原生逻辑
    MOM_start_of_path_orig
}
```

### 2. 层级判断机制

使用自定义堆栈 `my_group_stack` 准确判断程序组层级：

```tcl
# MOM_start_of_group 拦截器维护映射表
set my_group_level_map($gname) $pname
lappend my_group_stack $gname
```

### 3. 智能文件切换 (PB_CMD_smart_file_switch)

**核心逻辑**：
- Level 0: 根目录下工序 → 不建文件夹，文件名为工序名
- Level 1: 一级组下工序 → 文件夹为一级组名，文件名为工序名
- Level 2: 二级组下工序 → 文件夹为一级组名，文件名为二级组名（合并输出）

### 4. 防御性编程与异常隔离

```tcl
catch { set op_parent $mom_group_name }
if { ![info exists my_group_stack] } { set my_group_stack [list] }
if { [llength [info commands MOM_output_literal]] } { ... }
```

### 5. 终极兜底清理与突破死锁

**白名单机制**：只有经过 `PB_CMD_smart_file_switch` 路由生成的文件才加入 `my_valid_files` 白名单。

**流氓文件拦截**：在 `MOM_end_of_program` 阶段扫描根目录，对不在白名单中的 `.nc` 和 `.tmp` 文件执行强制删除。

### 6. 无刀库机床安全检查

采用"刀具名称+类型+直径+下半径+总长"构建指纹进行比对，避免仅凭刀号判断导致的误报。

```tcl
set current_tool_fingerprint "${current_tool_name}|${current_tool_type}|${current_tool_dia}|${current_tool_corner}|${current_tool_length}"
```

### 7. 路径规范化

强制使用 `string map {"\\" "/"}` 将所有反斜杠替换为正斜杠，消除路径解析错误。

## 📁 实际输出示例

```
NC/
├── LEFT2/
│   ├── LEF2-01.nc
│   ├── LEF2-02.nc
│   ├── LEF2-03.nc
│   ├── LEF2-04.nc
│   └── LEF2-05.nc
├── RIG/
│   ├── RIG-01.nc
│   ├── RIG-02.nc
│   ├── RIG-03.nc
│   ├── RIG-04.nc
│   └── RIG-05.nc
├── TOP/
│   ├── TOP-01.nc
│   ├── TOP-02.nc
│   ├── TOP-03.nc
│   ├── TOP-04.nc
│   └── TOP-05.nc
└── ...
```

**说明**：
- 一级组名（如 `TOP`）作为文件夹名
- 二级组名（如 `TOP-03`）作为 NC 文件名
- 同一二级组内的所有工序合并到一个文件中

## 🔑 核心变量说明

| 变量名 | 说明 | 用途 |
|--------|------|------|
| `my_group_stack` | 程序组堆栈 | 跟踪当前层级关系 |
| `my_group_level_map` | 组名映射表 | 存储父子组关系 |
| `my_valid_files` | 有效文件白名单 | 防止流氓文件残留 |
| `my_is_merged_op` | 合并操作标志 | 标识是否为二级组工序 |
| `SUB_GROUP_BASE_TOOL_FINGERPRINT` | 刀具指纹基准 | 二级组内刀具一致性校验 |
| `my_out_dir` | 输出目录 | 从环境变量或配置获取 |

## 🔄 执行流程

### 初始化阶段
```
PB_CMD_kin_start_of_program
  └─> PB_CMD_init_smart_grouping
        ├─> rename MOM_start_of_path → MOM_start_of_path_orig
        ├─> rename MOM_start_of_group → MOM_start_of_group_orig
        └─> 初始化 my_group_stack, my_valid_files
```

### 程序组处理
```
MOM_start_of_group (拦截器)
  ├─> 记录组名到 my_group_level_map
  ├─> 维护 my_group_stack 堆栈
  └─> 调用 MOM_start_of_group_orig

MOM_start_of_path (拦截器)
  ├─> PB_CMD_smart_file_switch
  │     ├─> 判断层级 (Level 0/1/2)
  │     ├─> 构建目标路径
  │     ├─> 刀具一致性检查
  │     └─> 执行文件切换
  └─> MOM_start_of_path_orig
```

### 清理阶段
```
MOM_end_of_program
  └─> 扫描并删除不在白名单中的 .nc/.tmp 文件
```

## ⚙️ 环境与配置

### 环境变量
- `UGII_CAM_OUTPUT_DIR`: NC 文件输出目录
- `UGII_CAM_POST_DIR`: 后处理文件所在目录

### 路径配置
- 输出路径从 `UGII_CAM_OUTPUT_DIR` 获取
- 如果未设置，回退到 `UGII_CAM_POST_DIR` 的上级目录
- 路径自动标准化：反斜杠 → 正斜杠

### 容错处理
- 目录创建失败 → 回退到输出目录本身
- 文件打开失败 → 使用 catch 捕获错误
- 变量不存在 → 使用 info exists 检查并提供默认值

## 📂 关键文件说明

### 1. new_post.tcl (主后处理文件)
- **PB_CMD_init_smart_grouping**: 初始化钩子和拦截器
- **PB_CMD_smart_file_switch**: 核心文件切换逻辑
- **MOM_start_of_path (重命名后)**: 接管路径切换
- **MOM_start_of_group (重命名后)**: 维护组堆栈

### 2. new_post.def (DEF 模板文件)
- 定义输出格式和地址
- 配置 G 代码、坐标格式等

### 3. new_post.pui (Post Builder 配置文件)
- Post Builder 图形界面配置
- 事件绑定和自定义命令

### 4. new_post_user.tcl (用户扩展文件)
- MOM_end_of_group 占位符
- 确保 NX 引擎能扫描到该事件

## 💡 使用建议与注意事项

### 1. 程序组命名规范
- 一级组：使用有意义的名称（如 `TOP`, `LEFT`, `RIGHT`）
- 二级组：建议使用 `-数字` 后缀（如 `TOP-01`, `TOP-02`）
- 避免特殊字符：`<>:"|?*` 会被自动替换为 `_`

### 2. 无刀库机床注意事项
- 二级组内所有工序必须使用同一把刀具
- 系统会自动检测刀具一致性并报警
- T/H/D 寄存器默认为 00

### 3. 调试技巧
- 查看 listing file (.lpt) 了解执行流程
- 检查 NC 文件头注释确认刀具参数
- 验证输出目录结构是否符合预期

### 4. 常见问题

**Q: 为什么某些文件没有被正确分类？**
A: 检查程序组层级是否正确，确保二级组命名符合规范。

**Q: 如何禁用刀具一致性检查？**
A: 在 `PB_CMD_smart_file_switch` 中注释掉相关检查代码。

**Q: 流氓文件清理太激进怎么办？**
A: 检查 `my_valid_files` 白名单是否正确维护。

### 5. 扩展开发
- 可在 `PB_CMD_smart_file_switch` 中添加自定义文件命名规则
- 可在 `MOM_start_of_path` 拦截器中添加额外的初始化逻辑
- 可在 DEF 文件中自定义程序头/尾模板

---

**最后更新**: 2026-04-24  
**GitHub**: https://github.com/whua898/NX12POST  
**NX 版本**: NX 12  
**后处理类型**: 3-Axis Mill  
**适用机床**: 无刀库数控机床

