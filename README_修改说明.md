# NX12 后处理程序组目录结构修改说明

## 问题描述

原始代码中，所有NC文件都被输出到单一的NC目录中，未能根据程序组名称自动创建子目录并生成对应的单独NC文件。

## 修改内容

### 1. **new_post.tcl 主文件修改**

#### (1) 在 `MOM_start_of_program` 中添加用户自定义处理（第409-412行）

```tcl
# 调用用户自定义的程序开始处理逻辑
if { [CMD_EXIST PB_CMD_user_start_of_program] } {
   PB_CMD_user_start_of_program
}
```

**作用**：在程序启动时调用自定义逻辑，识别并记录程序组名称。

#### (2) 在 `MOM_start_of_group` 中添加用户自定义处理（第608-611行）

```tcl
# 调用用户自定义的程序组开始处理逻辑
if { [CMD_EXIST PB_CMD_user_start_of_group] } {
   PB_CMD_user_start_of_group
}
```

**作用**：在每个程序组开始时调用，为二级程序组创建独立的NC输出文件。

#### (3) 新增 `MOM_end_of_group` 处理器（第615-630行）

```tcl
#=============================================================
proc MOM_end_of_group { } {
#=============================================================
   global group_level

   # 调用用户自定义的程序组结束处理逻辑
   if { [CMD_EXIST PB_CMD_user_end_of_group] } {
      PB_CMD_user_end_of_group
   }

   if { [hiset group_level] } {
      set group_level [expr {$group_level - 1}]
   }
}
```

**作用**：在每个程序组结束时调用，处理资源清理和文件关闭。

#### (4) 在 `MOM_end_of_program` 中添加用户自定义处理

```tcl
# 调用用户自定义的程序结束处理逻辑
if { [CMD_EXIST PB_CMD_user_end_of_program] } {
   PB_CMD_user_end_of_program
}
```

**作用**：在整个程序结束时调用，进行最终的清理工作。

### 2. **new_post_user.tcl 用户自定义文件修改**

#### (1) 改进 `PB_CMD_build_output_path` 函数

**主要改进**：
- 支持中文字符的路径名
- 完善的目录创建错误处理
- 从多个来源获取输出目录

**逻辑**：
```
输出目录 = UGII_CAM_OUTPUT_DIR 或 UGII_CAM_POST_DIR的上级目录
程序组子目录 = 输出目录 / 程序组名
输出文件 = 程序组子目录 / 操作名.nc
```

#### (2) 简化 `PB_CMD_user_start_of_program` 函数

**功能**：
- 获取程序组名和操作名
- 记录程序组信息（仅当非主程序时）

#### (3) 改进 `PB_CMD_user_start_of_group` 函数

**功能**：
- 处理二级程序组
- 为二级程序组创建独立NC文件

#### (4) 简化 `PB_CMD_user_end_of_group` 函数

**功能**：
- 清理二级程序组相关的全局变量

#### (5) 改进 `PB_CMD_user_end_of_program` 函数

**功能**：
- 程序结束时清空所有自定义全局变量

## 输出目录结构

修改后，NC文件将按如下结构组织：

```
NC/
├── 底面-工件1/
│   ├── GJ1B-01.nc
│   ├── GJ1B-02.nc
│   ├── GJ1B-03.nc
│   ├── GJ1B-04.nc
│   ├── GJ1B-05.nc
│   └── 底面-工件1.nc (组合文件)
├── 底面-工件2/
│   ├── GJ2B-01.nc
│   ├── GJ2B-02.nc
│   ├── GJ2B-03.nc
│   ├── GJ2B-04.nc
│   ├── GJ2B-05.nc
│   └── 底面-工件2.nc (组合文件)
├── 正面-工件1/
│   ├── GJ1T-01.nc
│   ├── GJ1T-011.nc
│   ├── GJ1T-012.nc
│   ├── GJ1T-03.nc
│   ├── GJ1T-04.nc
│   ├── GJ1T-05.nc
│   ├── GJ1T-06.nc
│   ├── GJ1T-07.nc
│   ├── GJ1T-08.nc
│   └── 正面-工件1.nc (组合文件)
└── 正面-工件2/
    ├── GJ2T-01.nc
    ├── GJ2T-02.nc
    ├── GJ2T-03.nc
    ├── GJ2T-04.nc
    ├── GJ2T-05.nc
    ├── GJ2T-06.nc
    ├── GJ2T-07.nc
    ├── GJ2T-08.nc
    ├── GJ2T-09.nc
    └── 正面-工件2.nc (组合文件)
```

## 核心变量说明

| 变量名 | 说明 | 作用域 |
|--------|------|--------|
| `mom_group_name` | 程序组名称 | 全局 |
| `group_level` | 程序组嵌套级别 (1=一级, 2+=二级及以上) | 全局 |
| `mom_operation_name` | 当前操作名称 | 全局 |
| `mom_sys_output_directory` | 输出目录基路径 | new_post_user.tcl |
| `mom_sys_output_file_name` | 当前输出文件完整路径 | 全局 |
| `mom_sys_current_group_file` | 当前程序组文件路径 | new_post_user.tcl |

## 调用流程

### 一级程序组（如 "NC_PROGRAM"）
```
MOM_start_of_program
  └─> PB_CMD_user_start_of_program (记录，但不创建单独文件)
        └─> 使用默认NC文件输出
```

### 二级程序组（如 "底面-工件1"）
```
MOM_start_of_group (group_level=2)
  └─> PB_CMD_user_start_of_group
        └─> PB_CMD_build_output_path
              └─> 创建 NC/底面-工件1/ 目录
              └─> 返回 NC/底面-工件1/底面-工件1.nc

(各操作输出到该文件)

MOM_end_of_group
  └─> PB_CMD_user_end_of_group
        └─> 清理相关变量
```

## 调试与验证

### 启用调试输出

在NX CAM后处理中，注释信息会被输出到NC文件。可通过以下标记跟踪执行过程：

- `(DEBUG: Group=xxx, Operation=yyy)` - 程序开始时的信息
- `(DEBUG: group_level=n, mom_group_name=xxx)` - 程序组级别信息
- `(DEBUG: End of group, level=n)` - 程序组结束时的信息

### 常见问题排查

1. **目录未创建**
   - 检查 UGII_CAM_OUTPUT_DIR 环境变量是否设置
   - 检查输出目录的写入权限

2. **NC文件名不正确**
   - 检查程序组名中的特殊字符（<>:"|?* 会被替换为_）
   - 检查操作名称是否正确传递

3. **文件输出到错误的位置**
   - 检查 group_level 值是否正确
   - 检查 mom_group_name 是否正确获取

## 技术细节

### 路径处理
- 支持Windows反斜杠和正斜杠自动转换
- 清理非法文件名字符（保留中文字符）
- 自动创建多级目录

### 错误容错
- 目录创建失败时回退到输出目录
- 文件打开失败时使用默认输出
- 所有文件操作都使用 catch 包装

### 性能优化
- 仅在必要时创建目录
- 缓存输出目录路径
- 避免重复的文件打开关闭操作

## 修改文件列表

1. **new_post.tcl** - 主后处理文件
   - 添加了 MOM_end_of_group 处理器
   - 在关键事件中添加了用户自定义程序调用

2. **new_post_user.tcl** - 用户自定义处理文件
   - 改进了路径构建逻辑
   - 完善了程序组处理函数

## 后续配置建议

1. **设置输出目录环境变量**
   ```tcl
   # 在NX启动前设置
   set env(UGII_CAM_OUTPUT_DIR) "D:/Users/wh898/PycharmProjects/NX12POST/NC"
   ```

2. **自定义路径规则**
   - 可在 `PB_CMD_build_output_path` 中修改目录命名规则
   - 例如：增加日期时间戳、添加工件号等

3. **扩展功能**
   - 可在 `PB_CMD_user_start_of_program` 中添加程序头信息
   - 可在 `PB_CMD_user_end_of_program` 中添加程序尾部信息
   - 可在 `PB_CMD_user_start_of_group` 中添加组头信息

---

**修改日期**: 2026-03-11
**NX版本**: NX 12
**后处理类型**: 3-Axis Mill

