# ==============================================================================
# 用户自定义 TCL 文件 (smart_post_user.tcl)
# ==============================================================================
# 说明：
# 此文件由 NX 后处理引擎在加载主 TCL 文件时自动 source（读取）。
# 放在此文件中的代码是【全局代码】，并且【永远不会】被 UG NX 后处理构造器
# (Post Builder) 覆盖或删除。
# ==============================================================================

# 确保 NX 引擎在初始化时能扫描到 MOM_end_of_group 事件，从而触发它。
# 这是解决 NX 漏发组结束事件的关键占位符。
if { ![llength [info commands MOM_end_of_group]] } {
    proc MOM_end_of_group { } {
        # 这是一个占位符，真正的逻辑在 PB_CMD_init_smart_grouping 中被拦截和重写
    }
}

# 根边界判断兜底：如果主后处理未定义该函数，用户 Tcl 也提供一份。
if { ![llength [info commands PB_CMD_is_cam_root_parent]] } {
    proc PB_CMD_is_cam_root_parent { group_name } {
        return [expr {$group_name == "" || $group_name == "NC_PROGRAM" || $group_name == "NONE"}]
    }
}


# ==============================================================================
# PB-safe T/H fallback hooks
# ==============================================================================
# These hooks live in smart_post_user.tcl, which is sourced after the PB-generated
# main Tcl file. PB can open/save the post without overwriting this logic.

if { ![llength [info commands PB_CMD_user_positive_int_or_zero]] } {
    proc PB_CMD_user_positive_int_or_zero { value } {
        set result 0
        catch {
            if { [scan $value "%d" result] != 1 } {
                set result 0
            }
        }
        if { ![string is integer -strict $result] || $result < 0 } {
            set result 0
        }
        return $result
    }
}

if { ![llength [info commands PB_CMD_user_first_positive_number_from_names]] } {
    proc PB_CMD_user_first_positive_number_from_names { } {
        global current_output_file mom_operation_name mom_group_name

        foreach name_var {current_output_file mom_operation_name mom_group_name} {
            if { [info exists $name_var] } {
                set name_value [set $name_var]
                if { $name_value != "" } {
                    set name_tail [file rootname [file tail $name_value]]
                    if { [regexp {(^|[^0-9])0*([1-9][0-9]*)} $name_tail match prefix number_text] } {
                        return [PB_CMD_user_positive_int_or_zero $number_text]
                    }
                }
            }
        }

        return 0
    }
}

if { ![llength [info commands PB_CMD_user_normalize_tool_registers]] } {
    proc PB_CMD_user_normalize_tool_registers { } {
        global mom_tool_number mom_next_tool_number
        global mom_tool_adjust_register mom_tool_length_adjust_register mom_length_comp_register
        global mom_sys_tool_number_min mom_sys_tool_number_max

        set tool_num 0
        if { [info exists mom_tool_number] } {
            set tool_num [PB_CMD_user_positive_int_or_zero $mom_tool_number]
        }

        set h_reg 0
        if { [info exists mom_tool_adjust_register] } {
            set h_reg [PB_CMD_user_positive_int_or_zero $mom_tool_adjust_register]
        }
        if { $h_reg == 0 && [info exists mom_tool_length_adjust_register] } {
            set h_reg [PB_CMD_user_positive_int_or_zero $mom_tool_length_adjust_register]
        }
        if { $h_reg == 0 && [info exists mom_length_comp_register] } {
            set h_reg [PB_CMD_user_positive_int_or_zero $mom_length_comp_register]
        }

        if { $tool_num == 0 && $h_reg > 0 } {
            set tool_num $h_reg
        }
        if { $h_reg == 0 && $tool_num > 0 } {
            set h_reg $tool_num
        }
        if { $tool_num == 0 && $h_reg == 0 } {
            set fallback_num [PB_CMD_user_first_positive_number_from_names]
            if { $fallback_num > 0 } {
                set tool_num $fallback_num
                set h_reg $fallback_num
            }
        }

        if { $tool_num > 0 && [info exists mom_sys_tool_number_min] && $tool_num < $mom_sys_tool_number_min } {
            set tool_num $mom_sys_tool_number_min
        }
        if { $tool_num > 0 && [info exists mom_sys_tool_number_max] && $tool_num > $mom_sys_tool_number_max } {
            set tool_num $mom_sys_tool_number_max
        }
        if { $h_reg == 0 && $tool_num > 0 } {
            set h_reg $tool_num
        }

        if { $tool_num > 0 } {
            set mom_tool_number $tool_num
            if { ![info exists mom_next_tool_number] || [PB_CMD_user_positive_int_or_zero $mom_next_tool_number] == 0 } {
                set mom_next_tool_number $tool_num
            }
        }
        if { $h_reg > 0 } {
            set mom_tool_adjust_register $h_reg
            if { ![info exists mom_tool_length_adjust_register] || [PB_CMD_user_positive_int_or_zero $mom_tool_length_adjust_register] == 0 } {
                set mom_tool_length_adjust_register $h_reg
            }
        }
    }
}

if { [llength [info commands PB_CMD_check_zero_tool]] && ![llength [info commands PB_CMD_check_zero_tool_PB_ORIG]] } {
    rename PB_CMD_check_zero_tool PB_CMD_check_zero_tool_PB_ORIG
    proc PB_CMD_check_zero_tool { } {
        PB_CMD_user_normalize_tool_registers

        global mom_tool_number mom_tool_adjust_register
        if { ![info exists mom_tool_number] || $mom_tool_number == 0 } {
            catch { output_literal_gbk "( 【警告】当前刀号为 0，请检查 CAM 刀具设置！ )" }
        }
        if { ![info exists mom_tool_adjust_register] || $mom_tool_adjust_register == 0 } {
            catch { output_literal_gbk "( 【警告】当前刀补号为 0，请检查 CAM 刀具设置！ )" }
        }
    }
}

if { [llength [info commands MOM_do_template]] && ![llength [info commands MOM_do_template_TOOL_FALLBACK_ORIG]] } {
    rename MOM_do_template MOM_do_template_TOOL_FALLBACK_ORIG
    proc MOM_do_template { template_name args } {
        if { [lsearch -exact {tool_change tool_change_1 tool_change_2 tool_length_adjust start_of_program} $template_name] >= 0 } {
            PB_CMD_user_normalize_tool_registers
        }
        if { [llength $args] > 0 } {
            return [eval MOM_do_template_TOOL_FALLBACK_ORIG [linsert $args 0 $template_name]]
        }
        return [MOM_do_template_TOOL_FALLBACK_ORIG $template_name]
    }
}

if { [llength [info commands PB_CMD_smart_file_switch]] && ![llength [info commands PB_CMD_smart_file_switch_TOOL_FALLBACK_ORIG]] } {
    rename PB_CMD_smart_file_switch PB_CMD_smart_file_switch_TOOL_FALLBACK_ORIG
    proc PB_CMD_smart_file_switch { } {
        PB_CMD_user_normalize_tool_registers
        PB_CMD_smart_file_switch_TOOL_FALLBACK_ORIG
    }
}

if { [llength [info commands PB_CMD_program_header]] && ![llength [info commands PB_CMD_program_header_TOOL_FALLBACK_ORIG]] } {
    rename PB_CMD_program_header PB_CMD_program_header_TOOL_FALLBACK_ORIG
    proc PB_CMD_program_header { } {
        PB_CMD_user_normalize_tool_registers
        PB_CMD_program_header_TOOL_FALLBACK_ORIG
    }
}

# ==============================================================================
# Last-mile NC buffer guard for blank H output
# ==============================================================================
# Some PB templates may suppress the H address even after the register is restored.
# Patch the output buffer before NX writes the block, without changing PB templates.

if { ![llength [info commands PB_CMD_user_current_h_register]] } {
    proc PB_CMD_user_current_h_register { } {
        global mom_tool_adjust_register mom_tool_length_adjust_register mom_tool_number

        PB_CMD_user_normalize_tool_registers

        set h_reg 0
        if { [info exists mom_tool_adjust_register] } {
            set h_reg [PB_CMD_user_positive_int_or_zero $mom_tool_adjust_register]
        }
        if { $h_reg == 0 && [info exists mom_tool_length_adjust_register] } {
            set h_reg [PB_CMD_user_positive_int_or_zero $mom_tool_length_adjust_register]
        }
        if { $h_reg == 0 && [info exists mom_tool_number] } {
            set h_reg [PB_CMD_user_positive_int_or_zero $mom_tool_number]
        }
        return $h_reg
    }
}

if { [llength [info commands MOM_before_output]] && ![llength [info commands MOM_before_output_TOOL_FALLBACK_ORIG]] } {
    rename MOM_before_output MOM_before_output_TOOL_FALLBACK_ORIG
    proc MOM_before_output { } {
        global mom_o_buffer

        if { [info exists mom_o_buffer] } {
            set h_reg [PB_CMD_user_current_h_register]
            if { $h_reg > 0 } {
                set h_text [format "H%02d" $h_reg]
                if { [regexp {(^|[[:space:]])G4[34]([[:space:]]*)$} $mom_o_buffer] } {
                    append mom_o_buffer " $h_text"
                }
                regsub -nocase {\(COMP:[[:space:]]*H0+} $mom_o_buffer "(COMP: $h_text" mom_o_buffer
            }
        }

        MOM_before_output_TOOL_FALLBACK_ORIG
    }
}


# ==============================================================================
# NX CAM hierarchy cache loader
# ==============================================================================
# The optional cache file is generated by get_cam_hierarchy_and_post.py before
# postprocessing. It provides the full Program View parent/path map to the post.

if { ![llength [info commands PB_CMD_user_load_cam_hierarchy_cache]] } {
    proc PB_CMD_user_load_cam_hierarchy_cache { } {
        global ptp_file_name my_out_dir my_group_level_map
        global nx_cam_parent nx_cam_path nx_cam_type nx_cam_depth nx_cam_selected_root
        global my_cam_hierarchy_cache_loaded my_cam_hierarchy_cache_file

        set my_cam_hierarchy_cache_loaded 0
        set my_cam_hierarchy_cache_file ""

        # 只有一键 Python Journal 调用时才读取缓存。
        # 普通 NX 后处理命令不会设置 NX_SMART_POST_USE_CACHE，避免误读历史旧缓存。
        set use_cache 0
        if { [info exists ::env(NX_SMART_POST_USE_CACHE)] && $::env(NX_SMART_POST_USE_CACHE) == "1" } {
            set use_cache 1
        }
        if { [info exists my_force_cam_hierarchy_cache] && $my_force_cam_hierarchy_cache == 1 } {
            set use_cache 1
        }
        if { !$use_cache } {
            return 0
        }

        set search_dirs [list]
        if { [info exists my_out_dir] && $my_out_dir != "" } {
            lappend search_dirs $my_out_dir
        }
        if { [info exists ptp_file_name] && $ptp_file_name != "" } {
            catch { lappend search_dirs [file dirname $ptp_file_name] }
        }
        catch {
            set output_dir [MOM_ask_env_var UGII_CAM_OUTPUT_DIR]
            if { $output_dir != "" } { lappend search_dirs $output_dir }
        }
        lappend search_dirs "."

        set cache_file ""
        foreach dir $search_dirs {
            if { $dir == "" } { continue }
            set candidate [file nativename [file join $dir "nx_cam_hierarchy.tcl"]]
            if { [file exists $candidate] } {
                set cache_file $candidate
                break
            }
        }
        if { $cache_file == "" } {
            # 不是通过 get_cam_hierarchy_and_post.py 调用时，这是正常情况。
            # 保持 my_group_level_map 为空，后续继续由 MOM_start_of_group 事件实时补全。
            return 0
        }

        if { [catch { source $cache_file } err] } {
            catch {
                set log_file [file nativename [file join [file dirname $cache_file] "nx_cam_hierarchy_load_error.log"]]
                set f [open $log_file a]
                puts $f "Failed to source $cache_file: $err"
                close $f
            }
            set my_cam_hierarchy_cache_loaded 0
            return 0
        }

        set my_cam_hierarchy_cache_file $cache_file
        set my_cam_hierarchy_cache_loaded 1

        if { [array exists nx_cam_parent] } {
            if { ![array exists my_group_level_map] } { array set my_group_level_map {} }
            foreach group_name [array names nx_cam_parent] {
                set parent_name $nx_cam_parent($group_name)
                if { $parent_name == "" } {
                    set parent_name "NONE"
                }
                set my_group_level_map($group_name) $parent_name
            }
        }
        return 1
    }
}
