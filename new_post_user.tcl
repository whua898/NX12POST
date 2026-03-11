########################################################################
# new_post_user.tcl - 用户自定义 TCL 脚本
# 功能：多级程序组后处理，支持目录创建和独立文件输出
########################################################################

# 全局变量声明
global mom_sys_output_directory
set mom_sys_output_directory ""

global mom_sys_group_level_map
set mom_sys_group_level_map ""

#=============================================================
proc PB_CMD_get_group_hierarchy { } {
#=============================================================
# 获取程序组层级信息
# 返回：{group_name level parent_group}
#
  global mom_group_name mom_group_id
  
  set group_info [list]
  
  # 获取当前组名
  if { [info exists mom_group_name] } {
     set current_group $mom_group_name
  } else {
     set current_group "NC_PROGRAM"
  }
  
  # 简化处理：直接返回当前组名
  return $current_group
}

#=============================================================
proc PB_CMD_build_output_path { group_name operation_name } {
#=============================================================
# 构建输出文件路径
# 参数:
#   group_name - 程序组名称
#   operation_name - 操作名称
# 返回：完整文件路径
#
  global mom_sys_output_directory mom_output_file_name
  
  # 获取输出目录 (从 NX 获取)
  if { ![info exists mom_sys_output_directory] || $mom_sys_output_directory == "" } {
     set mom_sys_output_directory [MOM_ask_env_var UGII_CAM_OUTPUT_DIR]
     if { $mom_sys_output_directory == "" } {
        set mom_sys_output_directory [file dirname [MOM_ask_env_var UGII_CAM_POST_DIR]]
     }
  }
  
  # 构建完整路径：输出目录/组名/文件名.nc
  set output_path [file join $mom_sys_output_directory $group_name]
  
  # 创建目录 (如果不存在)
  if { ![file exists $output_path] } {
     catch { file mkdir $output_path }
  }
  
  # 构建文件名
  if { [info exists operation_name] && $operation_name != "" } {
     set file_name "${operation_name}.nc"
  } else {
     set file_name "${group_name}.nc"
  }
  
  set full_path [file join $output_path $file_name]
  
  return $full_path
}

#=============================================================
proc PB_CMD_get_parent_group_name { } {
#=============================================================
# 获取父程序组名称 (简化版本)
# 实际项目中可能需要通过 NX Open API 获取
#
  # 这里简化处理，假设组名包含层级信息
  # 例如：RIGHT 是 TOP 的子组，组名可能是 "TOP\RIGHT"
  
  global mom_group_name
  
  # 首先检查组名是否存在
  if { ![info exists mom_group_name] || $mom_group_name == "" } {
     return ""
  }
  
  # 检查是否包含路径分隔符
  if { [string match "*\\*" $mom_group_name] } {
     # 包含反斜杠，说明是子组
     set parts [split $mom_group_name "\\"]
     if { [llength $parts] >= 2 } {
        return [lindex $parts end-1]
     }
  }
  
  # 如果没有路径分隔符，返回空 (说明是一级组)
  return ""
}

#=============================================================
proc PB_CMD_user_start_of_program { } {
#=============================================================
# 用户自定义程序开始处理
# 在 MOM_start_of_program 中调用
#
  global mom_group_name mom_operation_name mom_sys_output_file_name
  
  # 构建输出文件路径
  if { [info exists mom_group_name] && $mom_group_name != "" } {
     set output_file [PB_CMD_build_output_path $mom_group_name $mom_operation_name]
     
     # 设置输出文件
     catch { MOM_close_output_file $mom_sys_output_file_name }
     catch { MOM_open_output_file $output_file }
     set mom_sys_output_file_name $output_file
     
     MOM_output_literal "(OUTPUT FILE: $output_file)"
  }
}

#=============================================================
proc PB_CMD_user_start_of_group { } {
#=============================================================
# 用户自定义程序组开始处理
# 在 MOM_start_of_group 中调用
#
  global mom_group_name group_level mom_sys_output_file_name
  
  # 调试输出
  MOM_output_literal "(DEBUG: group_level=$group_level, mom_group_name=$mom_group_name)"
  
  # 处理二级程序组：为二级组创建独立 NC 文件
  if { $group_level > 1 } {
     # 获取父组名和当前组名
     set parent_group_name [PB_CMD_get_parent_group_name]
     
     # 只有找到父组名才处理
     if { $parent_group_name != "" && $mom_group_name != "" } {
        # 为二级组构建输出路径：父目录/二级组名.nc
        set output_file [PB_CMD_build_output_path $parent_group_name $mom_group_name]
        
        catch { MOM_close_output_file $mom_sys_output_file_name }
        catch { MOM_open_output_file $output_file }
        set mom_sys_output_file_name $output_file
        
        MOM_output_literal "(GROUP FILE: $output_file)"
     } else {
        # 找不到父组名时输出警告
        MOM_output_literal "(WARNING: Cannot determine parent group name for: $mom_group_name)"
     }
  }
  
  return
}

#=============================================================
proc PB_CMD_user_end_of_group { } {
#=============================================================
# 用户自定义程序组结束处理
# 在 MOM_end_of_group 中调用
#
  global mom_sys_output_file_name
  
  # 关闭当前输出文件
  if { [info exists mom_sys_output_file_name] } {
     catch { MOM_close_output_file $mom_sys_output_file_name }
     MOM_output_literal "(FILE CLOSED: $mom_sys_output_file_name)"
  }
}
