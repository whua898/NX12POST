# ==============================================================================
# 用户自定义 TCL 文件 (wv_user.tcl)
# ==============================================================================
# 说明：
# 此文件由 wv 后处理器加载，放置 PB 直接保存后也需要保留的轻量优化。
# 本文件不输出 Txx M06，也不启用换刀模板 tool_change_1。
# ==============================================================================

if { ![llength [info commands WV_USER_positive_int_or_zero]] } {
    proc WV_USER_positive_int_or_zero { value } {
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

if { ![llength [info commands WV_USER_normalize_h_register]] } {
    proc WV_USER_normalize_h_register { } {
        global mom_tool_adjust_register mom_tool_length_adjust_register mom_length_comp_register

        set h_reg 0
        if { [info exists mom_tool_adjust_register] } {
            set h_reg [WV_USER_positive_int_or_zero $mom_tool_adjust_register]
        }
        if { $h_reg == 0 && [info exists mom_tool_length_adjust_register] } {
            set h_reg [WV_USER_positive_int_or_zero $mom_tool_length_adjust_register]
        }
        if { $h_reg == 0 && [info exists mom_length_comp_register] } {
            set h_reg [WV_USER_positive_int_or_zero $mom_length_comp_register]
        }
        if { $h_reg == 0 } {
            set h_reg 1
        }

        set mom_tool_adjust_register $h_reg
        if { ![info exists mom_tool_length_adjust_register] || [WV_USER_positive_int_or_zero $mom_tool_length_adjust_register] == 0 } {
            set mom_tool_length_adjust_register $h_reg
        }
        return $h_reg
    }
}

if { [llength [info commands MOM_do_template]] && ![llength [info commands MOM_do_template_WV_USER_ORIG]] } {
    rename MOM_do_template MOM_do_template_WV_USER_ORIG
    proc MOM_do_template { template_name args } {
        if { [lsearch -exact {tool_length_adjust start_of_program start_of_program_1} $template_name] >= 0 } {
            WV_USER_normalize_h_register
        }
        if { [llength $args] > 0 } {
            return [eval MOM_do_template_WV_USER_ORIG [linsert $args 0 $template_name]]
        }
        return [MOM_do_template_WV_USER_ORIG $template_name]
    }
}

if { [llength [info commands MOM_before_output]] && ![llength [info commands MOM_before_output_WV_USER_ORIG]] } {
    rename MOM_before_output MOM_before_output_WV_USER_ORIG
    proc MOM_before_output { } {
        global mom_o_buffer

        if { [info exists mom_o_buffer] } {
            set h_reg [WV_USER_normalize_h_register]
            set h_text [format "H%02d" $h_reg]
            if { [regexp {(^|[[:space:]])G4[34]([[:space:]]*)$} $mom_o_buffer] } {
                append mom_o_buffer " $h_text"
            }
            if { [regexp -nocase {(^|[[:space:]])G4[34][[:space:]]+H0+([[:space:]]|$)} $mom_o_buffer] } {
                regsub -nocase {H0+} $mom_o_buffer $h_text mom_o_buffer
            }
        }

        MOM_before_output_WV_USER_ORIG
    }
}

if { [llength [info commands PB_CMD_tool_massge]] && ![llength [info commands PB_CMD_tool_massge_WV_USER_ORIG]] } {
    rename PB_CMD_tool_massge PB_CMD_tool_massge_WV_USER_ORIG
    proc PB_CMD_tool_massge { } {
        global mom_tool_diameter mom_tool_corner1_radius mom_stock_part

        set dia 0.0
        set radius 0.0
        set stock 0.0
        catch { set dia $mom_tool_diameter }
        catch { set radius $mom_tool_corner1_radius }
        catch { set stock $mom_stock_part }

        catch { MOM_output_literal "(DIA=[format %.2f $dia] R=[format %.2f $radius] STOCK=[format %.2f $stock]MM)" }
    }
}