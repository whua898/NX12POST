########################## TCL Event Handlers ##########################
#
#  new_post.tcl - 3_axis_mill
#
#    This is a 3-Axis Milling Machine.
#
#  Created by wh898 @ Saturday, April 11 2026, 18:11:01 +0800
#  with Post Builder version 12.0.2.
#
########################################################################



#=============================================================
proc PB_CMD___log_revisions { } {
#=============================================================
# Dummy command to log changes in this post --
#
# 15-Jul-2014 gsl - Initial version
#
}



  set cam_post_dir [MOM_ask_env_var UGII_CAM_POST_DIR]

  set mom_sys_this_post_dir  "[file dirname [info script]]"
  set mom_sys_this_post_name "[file rootname [file tail [info script]]]"


  if { ![info exists mom_sys_post_initialized] } {

     if { ![info exists mom_sys_ugpost_base_initialized] } {
        source ${cam_post_dir}ugpost_base.tcl
        set mom_sys_ugpost_base_initialized 1
     }


     set mom_sys_debug_mode OFF


     if { ![info exists env(PB_SUPPRESS_UGPOST_DEBUG)] } {
        set env(PB_SUPPRESS_UGPOST_DEBUG) 0
     }

     if { $env(PB_SUPPRESS_UGPOST_DEBUG) } {
        set mom_sys_debug_mode OFF
     }

     if { ![string compare $mom_sys_debug_mode "OFF"] } {

        proc MOM_before_each_add_var {} {}
        proc MOM_before_each_event   {} {}
        proc MOM_before_load_address {} {}
        proc MOM_end_debug {} {}

     } else {

        set cam_debug_dir [MOM_ask_env_var UGII_CAM_DEBUG_DIR]
        source ${cam_debug_dir}mom_review.tcl
     }


   ####  Listing File variables
     set mom_sys_list_output                       "OFF"
     set mom_sys_header_output                     "OFF"
     set mom_sys_list_file_rows                    "40"
     set mom_sys_list_file_columns                 "30"
     set mom_sys_warning_output                    "OFF"
     set mom_sys_warning_output_option             "FILE"
     set mom_sys_group_output                      "OFF"
     set mom_sys_list_file_suffix                  "lpt"
     set mom_sys_output_file_suffix                "nc"
     set mom_sys_commentary_output                 "ON"
     set mom_sys_commentary_list                   "x y z 4axis 5axis feed speed"
     set mom_sys_pb_link_var_mode                  "OFF"


     if { [string match "OFF" $mom_sys_warning_output] } {
        catch { rename MOM__util_print ugpost_MOM__util_print }
        proc MOM__util_print { args } {}
     }


     MOM_set_debug_mode $mom_sys_debug_mode


     if { [string match "OFF" $mom_sys_warning_output] } {
        catch { rename MOM__util_print "" }
        catch { rename ugpost_MOM__util_print MOM__util_print }
     }


   #=============================================================
   proc MOM_before_output { } {
   #=============================================================
   # This command is executed just before every NC block is
   # to be output to a file.
   #
   # - Never overload this command!
   # - Any customization should be done in PB_CMD_before_output!
   #

      if { [llength [info commands PB_CMD_kin_before_output]] &&\
           [llength [info commands PB_CMD_before_output]] } {

         PB_CMD_kin_before_output
      }

     # Write output buffer to the listing file with warnings
      global mom_sys_list_output
      if { [string match "ON" $mom_sys_list_output] } {
         LIST_FILE
      } else {
         global tape_bytes mom_o_buffer
         if { ![info exists tape_bytes] } {
            set tape_bytes [string length $mom_o_buffer]
         } else {
            incr tape_bytes [string length $mom_o_buffer]
         }
      }
   }


     if { [string match "OFF" [MOM_ask_env_var UGII_CAM_POST_LINK_VAR_MODE]] } {
        set mom_sys_link_var_mode                     "OFF"
     } else {
        set mom_sys_link_var_mode                     "$mom_sys_pb_link_var_mode"
     }


     set mom_sys_control_out                       "("
     set mom_sys_control_in                        ")"


     set mom_sys_post_initialized 1
  }


  set mom_sys_use_default_unit_fragment         "ON"
  set mom_sys_alt_unit_post_name                "new_post__IN.pui"


########## SYSTEM VARIABLE DECLARATIONS ##############
  set mom_sys_rapid_code                        "0"
  set mom_sys_linear_code                       "1"
  set mom_sys_circle_code(CLW)                  "2"
  set mom_sys_circle_code(CCLW)                 "3"
  set mom_sys_delay_code(SECONDS)               "4"
  set mom_sys_delay_code(REVOLUTIONS)           "4"
  set mom_sys_cutcom_plane_code(XY)             "17"
  set mom_sys_cutcom_plane_code(ZX)             "18"
  set mom_sys_cutcom_plane_code(XZ)             "18"
  set mom_sys_cutcom_plane_code(YZ)             "19"
  set mom_sys_cutcom_plane_code(ZY)             "19"
  set mom_sys_cutcom_code(OFF)                  "40"
  set mom_sys_cutcom_code(LEFT)                 "41"
  set mom_sys_cutcom_code(RIGHT)                "42"
  set mom_sys_adjust_code                       "43"
  set mom_sys_adjust_code_minus                 "44"
  set mom_sys_adjust_cancel_code                "49"
  set mom_sys_unit_code(IN)                     "70"
  set mom_sys_unit_code(MM)                     "71"
  set mom_sys_cycle_start_code                  "79"
  set mom_sys_cycle_off                         "80"
  set mom_sys_cycle_drill_code                  "81"
  set mom_sys_cycle_drill_dwell_code            "82"
  set mom_sys_cycle_drill_deep_code             "83"
  set mom_sys_cycle_drill_break_chip_code       "73"
  set mom_sys_cycle_tap_code                    "84"
  set mom_sys_cycle_bore_code                   "85"
  set mom_sys_cycle_bore_drag_code              "86"
  set mom_sys_cycle_bore_no_drag_code           "76"
  set mom_sys_cycle_bore_dwell_code             "89"
  set mom_sys_cycle_bore_manual_code            "88"
  set mom_sys_cycle_bore_back_code              "87"
  set mom_sys_cycle_bore_manual_dwell_code      "88"
  set mom_sys_output_code(ABSOLUTE)             "90"
  set mom_sys_output_code(INCREMENTAL)          "91"
  set mom_sys_cycle_ret_code(AUTO)              "98"
  set mom_sys_cycle_ret_code(MANUAL)            "99"
  set mom_sys_reset_code                        "92"
  set mom_sys_spindle_mode_code(SFM)            "96"
  set mom_sys_spindle_mode_code(RPM)            "97"
  set mom_sys_return_code                       "28"
  set mom_sys_feed_rate_mode_code(FRN)          "93"
  set mom_sys_feed_rate_mode_code(MMPM)         "94"
  set mom_sys_feed_rate_mode_code(MMPR)         "95"
  set mom_sys_feed_rate_mode_code(IPM)          "94"
  set mom_sys_feed_rate_mode_code(IPR)          "95"
  set mom_sys_program_stop_code                 "0"
  set mom_sys_optional_stop_code                "1"
  set mom_sys_end_of_program_code               "2"
  set mom_sys_spindle_direction_code(CLW)       "3"
  set mom_sys_spindle_direction_code(CCLW)      "4"
  set mom_sys_spindle_direction_code(OFF)       "5"
  set mom_sys_tool_change_code                  "6"
  set mom_sys_coolant_code(ON)                  "8"
  set mom_sys_coolant_code(FLOOD)               "8"
  set mom_sys_coolant_code(MIST)                "7"
  set mom_sys_coolant_code(THRU)                "26"
  set mom_sys_coolant_code(TAP)                 "27"
  set mom_sys_coolant_code(OFF)                 "9"
  set mom_sys_rewind_code                       "30"
  set mom_sys_4th_axis_has_limits               "1"
  set mom_sys_5th_axis_has_limits               "1"
  set mom_sys_sim_cycle_drill                   "0"
  set mom_sys_sim_cycle_drill_dwell             "0"
  set mom_sys_sim_cycle_drill_deep              "0"
  set mom_sys_sim_cycle_drill_break_chip        "0"
  set mom_sys_sim_cycle_tap                     "0"
  set mom_sys_sim_cycle_bore                    "0"
  set mom_sys_sim_cycle_bore_drag               "0"
  set mom_sys_sim_cycle_bore_nodrag             "0"
  set mom_sys_sim_cycle_bore_manual             "0"
  set mom_sys_sim_cycle_bore_dwell              "0"
  set mom_sys_sim_cycle_bore_manual_dwell       "0"
  set mom_sys_sim_cycle_bore_back               "0"
  set mom_sys_cir_vector                        "Vector - Arc Start to Center"
  set mom_sys_spindle_ranges                    "0"
  set mom_sys_rewind_stop_code                  "\#"
  set mom_sys_home_pos(0)                       "0"
  set mom_sys_home_pos(1)                       "0"
  set mom_sys_home_pos(2)                       "0"
  set mom_sys_zero                              "0"
  set mom_sys_opskip_block_leader               "/"
  set mom_sys_seqnum_start                      "10"
  set mom_sys_seqnum_incr                       "10"
  set mom_sys_seqnum_freq                       "1"
  set mom_sys_seqnum_max                        "9999"
  set mom_sys_lathe_x_double                    "1"
  set mom_sys_lathe_i_double                    "1"
  set mom_sys_lathe_y_double                    "1"
  set mom_sys_lathe_j_double                    "1"
  set mom_sys_lathe_x_factor                    "1"
  set mom_sys_lathe_y_factor                    "1"
  set mom_sys_lathe_z_factor                    "1"
  set mom_sys_lathe_i_factor                    "1"
  set mom_sys_lathe_j_factor                    "1"
  set mom_sys_lathe_k_factor                    "1"
  set mom_sys_leader(N)                         "N"
  set mom_sys_leader(X)                         "X"
  set mom_sys_leader(Y)                         "Y"
  set mom_sys_leader(Z)                         "Z"
  set mom_sys_leader(fourth_axis)               "B"
  set mom_sys_leader(fifth_axis)                "B"
  set mom_sys_contour_feed_mode(LINEAR)         "MMPM"
  set mom_sys_rapid_feed_mode(LINEAR)           "MMPM"
  set mom_sys_cycle_feed_mode                   "MMPM"
  set mom_sys_feed_param(IPM,format)            "Feed_IPM"
  set mom_sys_feed_param(IPR,format)            "Feed_IPR"
  set mom_sys_feed_param(FRN,format)            "Feed_INV"
  set mom_sys_vnc_rapid_dogleg                  "1"
  set mom_sys_prev_mach_head                    ""
  set mom_sys_curr_mach_head                    ""
  set mom_sys_feed_param(MMPM,format)           "Feed_MMPM"
  set mom_sys_feed_param(MMPR,format)           "Feed_MMPR"
  set mom_sys_advanced_turbo_output             "0"
  set mom_sys_tool_number_max                   "32"
  set mom_sys_tool_number_min                   "1"
  set mom_sys_post_description                  "This is a 3-Axis Milling Machine."
  set mom_sys_word_separator                    " "
  set mom_sys_end_of_block                      ""
  set mom_sys_ugpadvkins_used                   "0"
  set mom_sys_post_builder_version              "12.0.2"

####### KINEMATIC VARIABLE DECLARATIONS ##############
  set mom_kin_4th_axis_ang_offset               "0.0"
  set mom_kin_4th_axis_center_offset(0)         "0.0"
  set mom_kin_4th_axis_center_offset(1)         "0.0"
  set mom_kin_4th_axis_center_offset(2)         "0.0"
  set mom_kin_4th_axis_direction                "MAGNITUDE_DETERMINES_DIRECTION"
  set mom_kin_4th_axis_incr_switch              "OFF"
  set mom_kin_4th_axis_leader                   "B"
  set mom_kin_4th_axis_limit_action             "Warning"
  set mom_kin_4th_axis_max_limit                "360"
  set mom_kin_4th_axis_min_incr                 "0.001"
  set mom_kin_4th_axis_min_limit                "0"
  set mom_kin_4th_axis_plane                    "ZX"
  set mom_kin_4th_axis_point(0)                 "0.0"
  set mom_kin_4th_axis_point(1)                 "0.0"
  set mom_kin_4th_axis_point(2)                 "0.0"
  set mom_kin_4th_axis_rotation                 "standard"
  set mom_kin_4th_axis_type                     "Table"
  set mom_kin_4th_axis_vector(0)                "0.0"
  set mom_kin_4th_axis_vector(1)                "1.0"
  set mom_kin_4th_axis_vector(2)                "0.0"
  set mom_kin_4th_axis_zero                     "0.0"
  set mom_kin_5th_axis_center_offset(0)         "0.0"
  set mom_kin_5th_axis_center_offset(1)         "0.0"
  set mom_kin_5th_axis_center_offset(2)         "0.0"
  set mom_kin_5th_axis_incr_switch              "OFF"
  set mom_kin_5th_axis_max_limit                "0.0"
  set mom_kin_5th_axis_min_incr                 "0.0"
  set mom_kin_5th_axis_min_limit                "0.0"
  set mom_kin_5th_axis_point(0)                 "0.0"
  set mom_kin_5th_axis_point(1)                 "0.0"
  set mom_kin_5th_axis_point(2)                 "0.0"
  set mom_kin_5th_axis_vector(0)                "0.0"
  set mom_kin_5th_axis_vector(1)                "1.0"
  set mom_kin_5th_axis_vector(2)                "0.0"
  set mom_kin_5th_axis_zero                     "0.0"
  set mom_kin_arc_output_mode                   "QUADRANT"
  set mom_kin_arc_valid_plane                   "XYZ"
  set mom_kin_clamp_time                        "2.0"
  set mom_kin_cycle_plane_change_per_axis       "0"
  set mom_kin_cycle_plane_change_to_lower       "0"
  set mom_kin_flush_time                        "2.0"
  set mom_kin_linearization_flag                "1"
  set mom_kin_linearization_tol                 "0.01"
  set mom_kin_machine_resolution                ".001"
  set mom_kin_machine_type                      "3_axis_mill"
  set mom_kin_machine_zero_offset(0)            "0.0"
  set mom_kin_machine_zero_offset(1)            "0.0"
  set mom_kin_machine_zero_offset(2)            "0.0"
  set mom_kin_max_arc_radius                    "99999.999"
  set mom_kin_max_dpm                           "10000"
  set mom_kin_max_fpm                           "10000"
  set mom_kin_max_fpr                           "100"
  set mom_kin_max_frn                           "100"
  set mom_kin_min_arc_length                    "0.20"
  set mom_kin_min_arc_radius                    "0.001"
  set mom_kin_min_dpm                           "0.0"
  set mom_kin_min_fpm                           "0.01"
  set mom_kin_min_fpr                           "0.01"
  set mom_kin_min_frn                           "0.01"
  set mom_kin_output_unit                       "MM"
  set mom_kin_pivot_gauge_offset                "0.0"
  set mom_kin_pivot_guage_offset                ""
  set mom_kin_post_data_unit                    "MM"
  set mom_kin_rapid_feed_rate                   "15000"
  set mom_kin_rotary_axis_method                "PREVIOUS"
  set mom_kin_spindle_axis(0)                   "0.0"
  set mom_kin_spindle_axis(1)                   "0.0"
  set mom_kin_spindle_axis(2)                   "1.0"
  set mom_kin_tool_change_time                  "12.0"
  set mom_kin_x_axis_limit                      "4000"
  set mom_kin_y_axis_limit                      "2600"
  set mom_kin_z_axis_limit                      "1500"




if [llength [info commands MOM_SYS_do_template] ] {
   if [llength [info commands MOM_do_template] ] {
      rename MOM_do_template ""
   }
   rename MOM_SYS_do_template MOM_do_template
}




#=============================================================
proc MOM_start_of_program { } {
#=============================================================
  global mom_logname mom_date is_from
  global mom_coolant_status mom_cutcom_status
  global mom_clamp_status mom_cycle_status
  global mom_spindle_status mom_cutcom_plane pb_start_of_program_flag
  global mom_cutcom_adjust_register mom_tool_adjust_register
  global mom_tool_length_adjust_register mom_length_comp_register
  global mom_flush_register mom_wire_cutcom_adjust_register
  global mom_wire_cutcom_status

    set pb_start_of_program_flag 0
    set mom_coolant_status UNDEFINED
    set mom_cutcom_status  UNDEFINED
    set mom_clamp_status   UNDEFINED
    set mom_cycle_status   UNDEFINED
    set mom_spindle_status UNDEFINED
    set mom_cutcom_plane   UNDEFINED
    set mom_wire_cutcom_status  UNDEFINED

    catch {unset mom_cutcom_adjust_register}
    catch {unset mom_tool_adjust_register}
    catch {unset mom_tool_length_adjust_register}
    catch {unset mom_length_comp_register}
    catch {unset mom_flush_register}
    catch {unset mom_wire_cutcom_adjust_register}

    set is_from ""

    catch { OPEN_files } ;# Open warning and listing files
    LIST_FILE_HEADER     ;# List header in commentary listing



  global mom_sys_post_initialized
  if { $mom_sys_post_initialized > 1 } { return }


  set ::mom_sys_start_program_clock_seconds [clock seconds]

   # Load parameters for alternate output units
    PB_load_alternate_unit_settings
    rename PB_load_alternate_unit_settings ""


#************
uplevel #0 {


#=============================================================
proc MOM_sync { } {
#=============================================================
  if [llength [info commands PB_CMD_kin_handle_sync_event] ] {
    PB_CMD_kin_handle_sync_event
  }
}


#=============================================================
proc MOM_set_csys { } {
#=============================================================
  if [llength [info commands PB_CMD_kin_set_csys] ] {
    PB_CMD_kin_set_csys
  }
}


#=============================================================
proc MOM_msys { } {
#=============================================================
}


#=============================================================
proc MOM_end_of_program { } {
#=============================================================
  global mom_program_aborted mom_event_error
   PB_CMD_123
   MOM_set_seq_off
   PB_CMD_custom_program_footer

   MOM_do_template rewind_stop_code
   PB_CMD_cleanup_smart_grouping
   PB_CMD_SUB_GROUP_BASE_TOOL_FINGERPRINT

  # Write tool list with time in commentary data
   LIST_FILE_TRAILER

  # Close warning and listing files
   CLOSE_files

   if [CMD_EXIST PB_CMD_kin_end_of_program] {
      PB_CMD_kin_end_of_program
   }
}


  incr mom_sys_post_initialized


} ;# uplevel
#***********


}


#=============================================================
proc PB_init_new_iks { } {
#=============================================================
  global mom_kin_iks_usage mom_kin_spindle_axis
  global mom_kin_4th_axis_vector mom_kin_5th_axis_vector


   set mom_kin_iks_usage 1

  # Override spindle axis vector defined in PB_CMD_init_rotary
   set mom_kin_spindle_axis(0)  0.0
   set mom_kin_spindle_axis(1)  0.0
   set mom_kin_spindle_axis(2)  1.0

  # Unitize vectors
   foreach i { 0 1 2 } {
      set vec($i) $mom_kin_spindle_axis($i)
   }
   VEC3_unitize vec mom_kin_spindle_axis

   foreach i { 0 1 2 } {
      set vec($i) $mom_kin_4th_axis_vector($i)
   }
   VEC3_unitize vec mom_kin_4th_axis_vector

   foreach i { 0 1 2 } {
      set vec($i) $mom_kin_5th_axis_vector($i)
   }
   VEC3_unitize vec mom_kin_5th_axis_vector

  # Reload kinematics
   MOM_reload_kinematics
}


#=============================================================
proc PB_DELAY_TIME_SET { } {
#=============================================================
  global mom_sys_delay_param mom_delay_value
  global mom_delay_revs mom_delay_mode delay_time

  # Post Builder provided format for the current mode:
   if { [info exists mom_sys_delay_param(${mom_delay_mode},format)] != 0 } {
      MOM_set_address_format dwell $mom_sys_delay_param(${mom_delay_mode},format)
   }

   switch $mom_delay_mode {
      SECONDS { set delay_time $mom_delay_value }
      default { set delay_time $mom_delay_revs  }
   }
}


#=============================================================
proc MOM_before_motion { } {
#=============================================================
  global mom_motion_event mom_motion_type

   FEEDRATE_SET

   switch $mom_motion_type {
      ENGAGE   { PB_engage_move }
      APPROACH { PB_approach_move }
      FIRSTCUT { catch {PB_first_cut} }
      RETRACT  { PB_retract_move }
      RETURN   { catch {PB_return_move} }
      default  {}
   }

   if { [llength [info commands PB_CMD_kin_before_motion] ] } { PB_CMD_kin_before_motion }
   if { [llength [info commands PB_CMD_before_motion] ] }     { PB_CMD_before_motion }
}


#=============================================================
proc MOM_start_of_group { } {
#=============================================================
  global mom_sys_group_output mom_group_name group_level ptp_file_name
  global mom_sequence_number mom_sequence_increment mom_sequence_frequency
  global mom_sys_ptp_output pb_start_of_program_flag

   if { ![hiset group_level] } {
      set group_level 0
      return
   }

   if { [hiset mom_sys_group_output] } {
      if { ![string compare $mom_sys_group_output "OFF"] } {
         set group_level 0
         return
      }
   }

   if { [hiset group_level] } {
      incr group_level
   } else {
      set group_level 1
   }

   if { $group_level > 1 } {
      return
   }

   SEQNO_RESET ; #<4133654>
   MOM_reset_sequence $mom_sequence_number $mom_sequence_increment $mom_sequence_frequency

   if { [info exists ptp_file_name] } {
      MOM_close_output_file $ptp_file_name
      MOM_start_of_program
      if { ![string compare $mom_sys_ptp_output "ON"] } {
         MOM_open_output_file $ptp_file_name
      }
   } else {
      MOM_start_of_program
   }

   PB_start_of_program
   set pb_start_of_program_flag 1
}


#=============================================================
proc MOM_machine_mode { } {
#=============================================================
  global pb_start_of_program_flag
  global mom_operation_name mom_sys_change_mach_operation_name

   set mom_sys_change_mach_operation_name $mom_operation_name

   if { $pb_start_of_program_flag == 0 } {
      PB_start_of_program
      set pb_start_of_program_flag 1
   }

  # Reload post for simple mill-turn
   if { [llength [info commands PB_machine_mode] ] } {
      if { [catch {PB_machine_mode} res] } {
         CATCH_WARNING "$res"
      }
   }
}


#=============================================================
proc PB_FORCE { option args } {
#=============================================================
   set adds [join $args]
   if { [info exists option] && [llength $adds] } {
      lappend cmd MOM_force
      lappend cmd $option
      lappend cmd [join $adds]
      eval [join $cmd]
   }
}


#=============================================================
proc PB_SET_RAPID_MOD { mod_list blk_list ADDR NEW_MOD_LIST } {
#=============================================================
  upvar $ADDR addr
  upvar $NEW_MOD_LIST new_mod_list
  global mom_cycle_spindle_axis traverse_axis1 traverse_axis2


   set new_mod_list [list]

   foreach mod $mod_list {
      switch $mod {
         "rapid1" {
            set elem $addr($traverse_axis1)
            if { [lsearch $blk_list $elem] >= 0 } {
               lappend new_mod_list $elem
            }
         }
         "rapid2" {
            set elem $addr($traverse_axis2)
            if { [lsearch $blk_list $elem] >= 0 } {
               lappend new_mod_list $elem
            }
         }
         "rapid3" {
            set elem $addr($mom_cycle_spindle_axis)
            if { [lsearch $blk_list $elem] >= 0 } {
               lappend new_mod_list $elem
            }
         }
         default {
            set elem $mod
            if { [lsearch $blk_list $elem] >= 0 } {
               lappend new_mod_list $elem
            }
         }
      }
   }
}


########################
# Redefine FEEDRATE_SET
########################
if { [llength [info commands ugpost_FEEDRATE_SET] ] } {
   rename ugpost_FEEDRATE_SET ""
}

if { [llength [info commands FEEDRATE_SET] ] } {
   rename FEEDRATE_SET ugpost_FEEDRATE_SET
} else {
   proc ugpost_FEEDRATE_SET {} {}
}


#=============================================================
proc FEEDRATE_SET { } {
#=============================================================
   if { [llength [info commands PB_CMD_kin_feedrate_set] ] } {
      PB_CMD_kin_feedrate_set
   } else {
      ugpost_FEEDRATE_SET
   }
}


############## EVENT HANDLING SECTION ################


#=============================================================
proc MOM_auxfun { } {
#=============================================================
   MOM_do_template auxfun
}


#=============================================================
proc MOM_bore { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name BORE
   CYCLE_SET
}


#=============================================================
proc MOM_bore_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_bore
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_bore_back { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name BORE_BACK
   CYCLE_SET
}


#=============================================================
proc MOM_bore_back_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_bore_back
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_bore_drag { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name BORE_DRAG
   CYCLE_SET
}


#=============================================================
proc MOM_bore_drag_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_bore_drag
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_bore_dwell { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name BORE_DWELL
   CYCLE_SET
}


#=============================================================
proc MOM_bore_dwell_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_bore_dwell
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_bore_manual { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name BORE_MANUAL
   CYCLE_SET
}


#=============================================================
proc MOM_bore_manual_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_bore_manual
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_bore_manual_dwell { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name BORE_MANUAL_DWELL
   CYCLE_SET
}


#=============================================================
proc MOM_bore_manual_dwell_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_bore_manual_dwell
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_bore_no_drag { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name BORE_NO_DRAG
   CYCLE_SET
}


#=============================================================
proc MOM_bore_no_drag_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_bore_no_drag
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_circular_move { } {
#=============================================================
   ABORT_EVENT_CHECK

   CIRCLE_SET

   MOM_do_template circular_move
}


#=============================================================
proc MOM_coolant_off { } {
#=============================================================
   COOLANT_SET
}


#=============================================================
proc MOM_coolant_on { } {
#=============================================================
   COOLANT_SET
}


#=============================================================
proc MOM_cutcom_off { } {
#=============================================================
   CUTCOM_SET

   MOM_do_template cutcom_off
}


#=============================================================
proc MOM_cutcom_on { } {
#=============================================================
   CUTCOM_SET

   global mom_cutcom_adjust_register

   if { [info exists mom_cutcom_adjust_register] } {
      set cutcom_register_min 1
      set cutcom_register_max 99

      if { $mom_cutcom_adjust_register < $cutcom_register_min ||\
           $mom_cutcom_adjust_register > $cutcom_register_max } {

         CATCH_WARNING "CUTCOM register $mom_cutcom_adjust_register must be within the range between 1 and 99"

         unset mom_cutcom_adjust_register
      }
   }
}


#=============================================================
proc MOM_cycle_off { } {
#=============================================================
   MOM_do_template cycle_off
}


#=============================================================
proc MOM_cycle_plane_change { } {
#=============================================================
  global cycle_init_flag
  global mom_cycle_tool_axis_change
  global mom_cycle_clearance_plane_change

   set cycle_init_flag TRUE
}


#=============================================================
proc MOM_delay { } {
#=============================================================
   PB_DELAY_TIME_SET

   MOM_do_template delay
}


#=============================================================
proc MOM_drill { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name DRILL
   CYCLE_SET
}


#=============================================================
proc MOM_drill_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_drill
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_drill_break_chip { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name DRILL_BREAK_CHIP
   CYCLE_SET
}


#=============================================================
proc MOM_drill_break_chip_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_drill_break_chip
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_drill_deep { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name DRILL_DEEP
   CYCLE_SET
}


#=============================================================
proc MOM_drill_deep_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_drill_deep
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_drill_dwell { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name DRILL_DWELL
   CYCLE_SET
}


#=============================================================
proc MOM_drill_dwell_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_drill_dwell
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_drill_text { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name DRILL_TEXT
   CYCLE_SET
}


#=============================================================
proc MOM_drill_text_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_end_of_path { } {
#=============================================================
  global mom_sys_add_cutting_time mom_sys_add_non_cutting_time
  global mom_cutting_time mom_machine_time

  # Accumulated time should be in minutes.
   set mom_cutting_time [expr $mom_cutting_time + $mom_sys_add_cutting_time]
   set mom_machine_time [expr $mom_machine_time + $mom_sys_add_cutting_time + $mom_sys_add_non_cutting_time]
   MOM_reload_variable mom_cutting_time
   MOM_reload_variable mom_machine_time

   if [CMD_EXIST PB_CMD_kin_end_of_path] {
      PB_CMD_kin_end_of_path
   }

   global mom_sys_in_operation
   set mom_sys_in_operation 0
}


#=============================================================
proc MOM_end_of_subop_path { } {
#=============================================================
}


#=============================================================
proc MOM_first_move { } {
#=============================================================
  global mom_feed_rate mom_feed_rate_per_rev mom_motion_type
  global mom_kin_max_fpm mom_motion_event

   COOLANT_SET ; CUTCOM_SET ; SPINDLE_SET ; RAPID_SET

   catch { MOM_$mom_motion_event }

  # Configure turbo output settings
   if { [CMD_EXIST CONFIG_TURBO_OUTPUT] } {
      CONFIG_TURBO_OUTPUT
   }
}


#=============================================================
proc MOM_first_tool { } {
#=============================================================
  global mom_sys_first_tool_handled

  # First tool only gets handled once
   if { [info exists mom_sys_first_tool_handled] } {
      MOM_tool_change
      return
   }

   set mom_sys_first_tool_handled 1

   MOM_tool_change
}


#=============================================================
proc MOM_from_move { } {
#=============================================================
  global mom_feed_rate mom_feed_rate_per_rev  mom_motion_type mom_kin_max_fpm

   COOLANT_SET ; CUTCOM_SET ; SPINDLE_SET ; RAPID_SET

}


#=============================================================
proc MOM_gohome_move { } {
#=============================================================
   MOM_rapid_move
}


#=============================================================
proc MOM_initial_move { } {
#=============================================================
  global mom_feed_rate mom_feed_rate_per_rev mom_motion_type
  global mom_kin_max_fpm mom_motion_event

   COOLANT_SET ; CUTCOM_SET ; SPINDLE_SET ; RAPID_SET


  global mom_programmed_feed_rate
   if { [EQ_is_equal $mom_programmed_feed_rate 0] } {
      MOM_rapid_move
   } else {
      MOM_linear_move
   }

  # Configure turbo output settings
   if { [CMD_EXIST CONFIG_TURBO_OUTPUT] } {
      CONFIG_TURBO_OUTPUT
   }
}


#=============================================================
proc MOM_length_compensation { } {
#=============================================================
   TOOL_SET MOM_length_compensation
}


#=============================================================
proc MOM_linear_move { } {
#=============================================================
  global feed_mode mom_feed_rate mom_kin_rapid_feed_rate

   if { ![string compare $feed_mode "IPM"] || ![string compare $feed_mode "MMPM"] } {
      if { [EQ_is_ge $mom_feed_rate $mom_kin_rapid_feed_rate] } {
         MOM_rapid_move
         return
      }
   }

   ABORT_EVENT_CHECK

   HANDLE_FIRST_LINEAR_MOVE

   MOM_do_template linear_move
}


#=============================================================
proc MOM_load_tool { } {
#=============================================================
   global mom_tool_change_type mom_manual_tool_change
   global mom_tool_number mom_next_tool_number
   global mom_sys_tool_number_max mom_sys_tool_number_min

   if { $mom_tool_number < $mom_sys_tool_number_min || \
        $mom_tool_number > $mom_sys_tool_number_max } {

      global mom_warning_info
      set mom_warning_info "Tool number to be output ($mom_tool_number) exceeds limits of\
                            ($mom_sys_tool_number_min/$mom_sys_tool_number_max)"
      MOM_catch_warning
   }
}


#=============================================================
proc MOM_opstop { } {
#=============================================================
   MOM_do_template opstop
}


#=============================================================
proc MOM_prefun { } {
#=============================================================
   MOM_do_template prefun
}


#=============================================================
proc MOM_rapid_move { } {
#=============================================================
  global rapid_spindle_inhibit rapid_traverse_inhibit
  global spindle_first is_from
  global mom_cycle_spindle_axis traverse_axis1 traverse_axis2
  global mom_motion_event

   ABORT_EVENT_CHECK

   set spindle_first NONE

   set aa(0) X ; set aa(1) Y ; set aa(2) Z

   RAPID_SET

   set rapid_spindle_blk {G_motion G_mode X Y Z}
   set rapid_spindle_x_blk {G_motion G_mode X}
   set rapid_spindle_y_blk {G_motion G_mode Y}
   set rapid_spindle_z_blk {G_motion G_mode Z}
   set rapid_traverse_blk {G_motion G_mode X Y Z S M_spindle}
   set rapid_traverse_xy_blk {G_motion G_mode X Y S M_spindle}
   set rapid_traverse_yz_blk {G_motion G_mode Y Z S M_spindle}
   set rapid_traverse_xz_blk {G_motion G_mode X Z S M_spindle}
   set rapid_traverse_mod {}
   set rapid_spindle_mod {}

   global mom_sys_control_out mom_sys_control_in
   set co "$mom_sys_control_out"
   set ci "$mom_sys_control_in"


   if { ![info exists mom_cycle_spindle_axis] } {
      set mom_cycle_spindle_axis 2
   }
   if { ![info exists spindle_first] } {
      set spindle_first NONE
   }
   if { ![info exists rapid_spindle_inhibit] } {
      set rapid_spindle_inhibit FALSE
   }
   if { ![info exists rapid_traverse_inhibit] } {
      set rapid_traverse_inhibit FALSE
   }

   switch $mom_cycle_spindle_axis {
      0 {
         if [llength $rapid_spindle_x_blk] {
            set spindle_block  rapid_spindle_x
            PB_SET_RAPID_MOD $rapid_spindle_mod $rapid_spindle_x_blk aa mod_spindle
         } else {
            set spindle_block  ""
         }
         if [llength $rapid_traverse_yz_blk] {
            set traverse_block rapid_traverse_yz
            PB_SET_RAPID_MOD $rapid_traverse_mod $rapid_traverse_yz_blk aa mod_traverse
         } else {
            set traverse_block  ""
         }
      }

      1 {
         if [llength $rapid_spindle_y_blk] {
            set spindle_block  rapid_spindle_y
            PB_SET_RAPID_MOD $rapid_spindle_mod $rapid_spindle_y_blk aa mod_spindle
         } else {
            set spindle_block  ""
         }
         if [llength $rapid_traverse_xz_blk] {
            set traverse_block rapid_traverse_xz
            PB_SET_RAPID_MOD $rapid_traverse_mod $rapid_traverse_xz_blk aa mod_traverse
         } else {
            set traverse_block  ""
         }
      }

      2 {
         if [llength $rapid_spindle_z_blk] {
            set spindle_block  rapid_spindle_z
            PB_SET_RAPID_MOD $rapid_spindle_mod $rapid_spindle_z_blk aa mod_spindle
         } else {
            set spindle_block  ""
         }
         if [llength $rapid_traverse_xy_blk] {
            set traverse_block rapid_traverse_xy
            PB_SET_RAPID_MOD $rapid_traverse_mod $rapid_traverse_xy_blk aa mod_traverse
         } else {
            set traverse_block  ""
         }
      }

      default {
         set spindle_block  rapid_spindle
         set traverse_block rapid_traverse
         PB_SET_RAPID_MOD $rapid_spindle_mod $rapid_spindle_blk aa mod_spindle
         PB_SET_RAPID_MOD $rapid_traverse_mod $rapid_traverse_blk aa mod_traverse
      }
   }

   if { ![string compare $spindle_first "TRUE"] } {
      if { ![string compare $rapid_spindle_inhibit "FALSE"] } {
         if { [string compare $spindle_block ""] } {
            PB_FORCE Once $mod_spindle
            MOM_do_template $spindle_block
         } else {
            MOM_output_literal "$co Rapid Spindle Block is empty! $ci"
         }
      }
      if { ![string compare $rapid_traverse_inhibit "FALSE"] } {
         if { [string compare $traverse_block ""] } {
            PB_FORCE Once $mod_traverse
            MOM_do_template $traverse_block
         } else {
            MOM_output_literal "$co Rapid Traverse Block is empty! $ci"
         }
      }
   } elseif { ![string compare $spindle_first "FALSE"] } {
      if { ![string compare $rapid_traverse_inhibit "FALSE"] } {
         if { [string compare $traverse_block ""] } {
            PB_FORCE Once $mod_traverse
            MOM_do_template $traverse_block
         } else {
            MOM_output_literal "$co Rapid Traverse Block is empty! $ci"
         }
      }
      if { ![string compare $rapid_spindle_inhibit "FALSE"] } {
         if { [string compare $spindle_block ""] } {
            PB_FORCE Once $mod_spindle
            MOM_do_template $spindle_block
         } else {
            MOM_output_literal "$co Rapid Spindle Block is empty! $ci"
         }
      }
   } else {
      PB_FORCE Once $mod_traverse
      MOM_do_template rapid_traverse
   }
}


#=============================================================
proc MOM_sequence_number { } {
#=============================================================
   SEQNO_SET
}


#=============================================================
proc MOM_set_modes { } {
#=============================================================
   MODES_SET
}


#=============================================================
proc MOM_spindle_off { } {
#=============================================================
   MOM_do_template spindle_off
}


#=============================================================
proc MOM_spindle_rpm { } {
#=============================================================
   SPINDLE_SET

   MOM_force Once S M_spindle
   MOM_do_template spindle_rpm
}


#=============================================================
proc MOM_start_of_path { } {
#=============================================================
  global mom_sys_in_operation
   set mom_sys_in_operation 1

  global first_linear_move ; set first_linear_move 0
   TOOL_SET MOM_start_of_path

  global mom_sys_add_cutting_time mom_sys_add_non_cutting_time
  global mom_sys_machine_time mom_machine_time
   set mom_sys_add_cutting_time 0.0
   set mom_sys_add_non_cutting_time 0.0
   set mom_sys_machine_time $mom_machine_time

   if [CMD_EXIST PB_CMD_kin_start_of_path] {
      PB_CMD_kin_start_of_path
   }

   PB_CMD_start_of_operation_force_addresses
   PB_CMD_record_parent_group
}


#=============================================================
proc MOM_start_of_subop_path { } {
#=============================================================
}


#=============================================================
proc MOM_stop { } {
#=============================================================
   MOM_do_template stop
}


#=============================================================
proc MOM_tap { } {
#=============================================================
  global cycle_name
  global cycle_init_flag

   set cycle_init_flag TRUE
   set cycle_name TAP
   CYCLE_SET
}


#=============================================================
proc MOM_tap_move { } {
#=============================================================
   global cycle_init_flag


   ABORT_EVENT_CHECK

   PB_CMD_set_cycle_plane

   MOM_do_template cycle_tap
   set cycle_init_flag FALSE
}


#=============================================================
proc MOM_tool_change { } {
#=============================================================
   global mom_tool_change_type mom_manual_tool_change
   global mom_tool_number mom_next_tool_number
   global mom_sys_tool_number_max mom_sys_tool_number_min

   if { $mom_tool_number < $mom_sys_tool_number_min || \
        $mom_tool_number > $mom_sys_tool_number_max } {

      global mom_warning_info
      set mom_warning_info "Tool number to be output ($mom_tool_number) exceeds limits of\
                            ($mom_sys_tool_number_min/$mom_sys_tool_number_max)"
      MOM_catch_warning
   }

   if { [info exists mom_tool_change_type] } {
      switch $mom_tool_change_type {
         MANUAL { PB_manual_tool_change }
         AUTO   { PB_auto_tool_change }
      }
   } elseif { [info exists mom_manual_tool_change] } {
      if { ![string compare $mom_manual_tool_change "TRUE"] } {
         PB_manual_tool_change
      }
   }
}


#=============================================================
proc MOM_tool_preselect { } {
#=============================================================
   global mom_tool_preselect_number mom_tool_number mom_next_tool_number
   global mom_sys_tool_number_max mom_sys_tool_number_min

   if { [info exists mom_tool_preselect_number] } {
      if { $mom_tool_preselect_number < $mom_sys_tool_number_min || \
           $mom_tool_preselect_number > $mom_sys_tool_number_max } {

         global mom_warning_info
         set mom_warning_info "Preselected Tool number ($mom_tool_preselect_number) exceeds limits of\
                               ($mom_sys_tool_number_min/$mom_sys_tool_number_max)"
         MOM_catch_warning
      }

      set mom_next_tool_number $mom_tool_preselect_number
   }

}


#=============================================================
proc PB_approach_move { } {
#=============================================================
}


#=============================================================
proc PB_auto_tool_change { } {
#=============================================================
   global mom_tool_number mom_next_tool_number
   if { ![info exists mom_next_tool_number] } {
      set mom_next_tool_number $mom_tool_number
   }

   PB_CMD_check_zero_tool
}


#=============================================================
proc PB_engage_move { } {
#=============================================================
}


#=============================================================
proc PB_first_cut { } {
#=============================================================
}


#=============================================================
proc PB_first_linear_move { } {
#=============================================================
  global mom_sys_first_linear_move

  # Set this variable to signal 1st linear move has been handled.
   set mom_sys_first_linear_move 1

}


#=============================================================
proc PB_manual_tool_change { } {
#=============================================================
   PB_CMD_check_zero_tool
}


#=============================================================
proc PB_retract_move { } {
#=============================================================
}


#=============================================================
proc PB_return_move { } {
#=============================================================
}


#=============================================================
proc PB_start_of_program { } {
#=============================================================
   if [CMD_EXIST PB_CMD_kin_start_of_program] {
      PB_CMD_kin_start_of_program
   }

   PB_CMD_init_smart_grouping
   MOM_set_seq_off

   MOM_do_template rewind_stop_code
   PB_CMD_program_header

   MOM_do_template start_of_program

   MOM_do_template start_of_program_highspeed
   PB_CMD_init_helix

   if [CMD_EXIST PB_CMD_kin_start_of_program_2] {
      PB_CMD_kin_start_of_program_2
   }
}


#=============================================================
proc PB_CMD_123 { } {
#=============================================================
global mom_machine_time
global my_prev_machine_time

if {![info exists mom_machine_time] || $mom_machine_time == ""} { set mom_machine_time 0.0 }
if {![info exists my_prev_machine_time] || $my_prev_machine_time == ""} { set my_prev_machine_time 0.0 }

set op_time [expr $mom_machine_time - $my_prev_machine_time]
set my_prev_machine_time $mom_machine_time

if { [catch {set mom_my_op_time [format "%.2f" $op_time]}] } { set mom_my_op_time "0.00" }
catch { MOM_do_template operation_time_info }
if { [catch {set mom_my_machine_time [format "%.2f" $mom_machine_time]}] } { set mom_my_machine_time "0.00" }
catch { MOM_do_template machine_time_info }
}


#=============================================================
proc PB_CMD_FEEDRATE_NUMBER { } {
#=============================================================
#  This custom command is called by FEEDRATE_SET;
#  it allows you to modify the feed rate number after being
#  calculated by the system.
#
#<03-13-08 gsl> - Added use of frn factor (defined in ugpost_base.tcl) & max frn here
#                 Use global frn factor (defined as 1.0 in ugpost_base.tcl) or
#                 define a custom one here

   global mom_feed_rate_number
   global mom_sys_frn_factor
   global mom_kin_max_frn

  # set mom_sys_frn_factor 1.0

   set f 0.0

   if { [info exists mom_feed_rate_number] } {
      set f [expr $mom_feed_rate_number * $mom_sys_frn_factor]
      if { [EQ_is_gt $f $mom_kin_max_frn] } {
         set f $mom_kin_max_frn
      }
   }

return $f
}


#=============================================================
proc PB_CMD_MOM_insert { } {
#=============================================================
# Default PB generated handler for UDE MOM_insert
# - Do not attach it to any event!
#
# This procedure is executed when the Insert command is activated.
#
   global mom_Instruction
   MOM_output_literal "$mom_Instruction"
}


#=============================================================
proc PB_CMD_MOM_operator_message { } {
#=============================================================
# Default PB generated handler for UDE MOM_operator_message
# - Do not attach it to any event!
#
# This procedure is executed when the Operator Message command is activated.
#
# 28-Apr-2017 ugs - Of pb1102mp
#
   global mom_operator_message mom_operator_message_defined
   global mom_operator_message_status
   global ptp_file_name group_output_file mom_group_name
   global mom_sys_commentary_output
   global mom_sys_control_in
   global mom_sys_control_out
   global mom_sys_ptp_output
   global mom_post_in_simulation

   if { [info exists mom_operator_message_defined] && $mom_operator_message_defined == 0 } {
return
   }

   if { ![string match "ON" $mom_operator_message] && ![string match "OFF" $mom_operator_message] } {

      set brac_start [string first \( $mom_operator_message]
      set brac_end   [string last  \) $mom_operator_message]

      if { $brac_start != 0 } {
         set text_string "("
      } else {
         set text_string ""
      }

      append text_string $mom_operator_message
      if { $brac_end == -1 || \
           $brac_end != [expr [string length $mom_operator_message] -1 ] } {
         append text_string ")"
      }

      set st [MOM_set_seq_off]

     # Suspend output to PTP
      MOM_close_output_file $ptp_file_name

      if { [info exists mom_group_name] && [info exists group_output_file($mom_group_name)] } {
         MOM_close_output_file $group_output_file($mom_group_name)
      }

     # 5767232 -
     # 6686893 - seq num were output in nx6
     # if { [string match "on" $st] } { MOM_suppress once N }

     #<01Jun2011 wbh> Only output text to commentary file when postprocessing
      if { ![info exists mom_post_in_simulation] || $mom_post_in_simulation == 0 } {
         MOM_output_literal $text_string
      }

     # Resume output to PTP
      if { [string match "ON" $mom_sys_ptp_output] } {
         MOM_open_output_file $ptp_file_name
      }

      if { [info exists mom_group_name] && [info exists group_output_file($mom_group_name)] } {
         MOM_open_output_file $group_output_file($mom_group_name)
      }

      if { [string match "on" $st] } { MOM_set_seq_on }

      set need_commentary $mom_sys_commentary_output
      set mom_sys_commentary_output OFF

      set text_string [string map [list ")" $mom_sys_control_in] $text_string]
      set text_string [string map [list "(" $mom_sys_control_out] $text_string]

      MOM_output_literal $text_string

      set mom_sys_commentary_output $need_commentary

   } else {

      set mom_operator_message_status $mom_operator_message
   }
}


#=============================================================
proc PB_CMD_MOM_opskip_off { } {
#=============================================================
# Default PB generated handler for UDE MOM_opskip_off
# - Do not attach it to any event!
#
# This procedure is executed when the Optional skip command is activated.
#

   MOM_set_line_leader off $::mom_sys_opskip_block_leader
   set ::mom_sys_opskip_on 0
}


#=============================================================
proc PB_CMD_MOM_opskip_on { } {
#=============================================================
# Default PB generated handler for UDE MOM_opskip_on
# - Do not attach it to any event!
#
# <Note> Current MOM/Post implementation only handles opskip string appearing at the start of a block;
#        and by default, it only supports one level of opskip control.
#
# This procedure is executed when the Optional skip command is activated.
#

   MOM_set_line_leader always $::mom_sys_opskip_block_leader
   set ::mom_sys_opskip_on 1
}


#=============================================================
proc PB_CMD_MOM_pprint { } {
#=============================================================
# Default PB generated handler for UDE MOM_pprint
# - Do not attach it to any event!
#
# This procedure is executed when the PPrint command is activated.
#
   global mom_pprint_defined

   if { [info exists mom_pprint_defined] } {
      if { $mom_pprint_defined == 0 } {
return
      }
   }

   PPRINT_OUTPUT
}


#=============================================================
proc PB_CMD_MOM_text { } {
#=============================================================
# Default PB generated handler for UDE MOM_text
# - Do not attach it to any event!
#
# This procedure is executed when the Text command is activated.
#
   global mom_user_defined_text mom_record_fields
   global mom_sys_control_out mom_sys_control_in
   global mom_record_text mom_pprint set mom_Instruction mom_operator_message
   global mom_pprint_defined mom_operator_message_defined

   switch $mom_record_fields(0) {
   "PPRINT"
         {
            set mom_pprint_defined 1
            set mom_pprint $mom_record_text
            MOM_pprint
         }
   "INSERT"
         {
            set mom_Instruction $mom_record_text
            MOM_insert
         }
   "DISPLY"
         {
            set mom_operator_message_defined 1
            set mom_operator_message $mom_record_text
            MOM_operator_message
         }
   default
         {
            if {[info exists mom_user_defined_text]} {
               MOM_output_literal "${mom_sys_control_out}${mom_user_defined_text}${mom_sys_control_in}"
            }
         }
   }
}


#=============================================================
proc PB_CMD_SUB_GROUP_BASE_TOOL_FINGERPRINT { } {
#=============================================================
global SUB_GROUP_BASE_TOOL_FINGERPRINT
if { [info exists SUB_GROUP_BASE_TOOL_FINGERPRINT] } {
    unset SUB_GROUP_BASE_TOOL_FINGERPRINT
}
}


#=============================================================
proc PB_CMD__config_post_options { } {
#=============================================================
# <PB v10.03>
# This command should be called by Start-of-Program event;
# it enables users to set options (not via UI) that would
# affect the behavior and output of this post.
#
# Comment out next line to activate this command
return

  # <PB v10.03>
  # - Feed mode for RETRACT motion has been handled as RAPID,
  #   next option enables users to treat RETRACT as CONTOURing.
  #
   if { ![info exists ::mom_sys_retract_feed_mode] } {
      set ::mom_sys_retract_feed_mode  "CONTOUR"
   }
}


#=============================================================
proc PB_CMD__manage_part_attributes { } {
#=============================================================
# This command allows the user to manage the MOM variables
# generated for the part attributes, in case of conflicts.
#
# ==> This command is executed automatically when present in
#     the post. DO NOT add or call it in any event or command.
#

  # This command should only be called by MOM__part_attributes!
   if { ![CALLED_BY "MOM__part_attributes"] } {
return
   }

  #+++++++++++++++++++++++++++++++++++++
  # You may manage part attributes here
  #+++++++++++++++++++++++++++++++++++++
}


#=============================================================
proc PB_CMD_abort_event { } {
#=============================================================
# This command is automatically called by every motion event
# to abort its handler based on the flag set by other events
# under certain conditions, such as an invalid tool axis vector.
#
# Users can set the global variable mom_sys_abort_next_event to
# different severity levels (non-zero) throughout the post and
# designate how to handle different conditions in this command.
#
# - Rapid, linear, circular and cycle move events have this trigger
#   built in by default in PB6.0.
#
# 06-17-13 gsl - Do not abort event, by default, when signal is "1".
# 07-16-15 gsl - Added level 3 handling

   if { [info exists ::mom_sys_abort_next_event] } {

      switch $::mom_sys_abort_next_event {
         2 -
         3 {
           # User may choose to abort NX/Post
            set __abort_post 0

            if { $__abort_post } {
               set msg "NX/Post Aborted: Illegal Move ($::mom_sys_abort_next_event)"

               if { [info exists ::mom_post_in_simulation] && $::mom_post_in_simulation == "MTD" } {
                 # In simulation, user will choose "Cancel" to stop the process.
                  PAUSE MOM_abort $msg
               } else {
                  MOM_abort $msg
               }
            }

           # Level 2 only aborts current event; level 3 will abort entire motion.
            if { $::mom_sys_abort_next_event == 2 } {
               unset ::mom_sys_abort_next_event
            }

            CATCH_WARNING "Event aborted!"
            MOM_abort_event
         }
         default {
            unset ::mom_sys_abort_next_event
            CATCH_WARNING "Event warned!"
         }
      }

   }
}


#=============================================================
proc PB_CMD_ask_machine_type { } {
#=============================================================
# Utility to return machine type per mom_kin_machine_type
#
# Revisions:
#-----------
# 02-26-09 gsl - Initial version
#
   global mom_kin_machine_type

   if { [string match "*wedm*" $mom_kin_machine_type] } {
return WEDM
   } elseif { [string match "*axis*" $mom_kin_machine_type] } {
return MILL
   } elseif { [string match "*lathe*" $mom_kin_machine_type] } {
return TURN
   } else {
return $mom_kin_machine_type
   }
}


#=============================================================
proc PB_CMD_before_motion { } {
#=============================================================

}


#=============================================================
proc PB_CMD_build_output_path { } {
#=============================================================
  # 构建输出文件路径
  # 参数:
  #   group_name - 程序组名称
  #   operation_name - 操作名称
  # 返回:完整文件路径
  #
  global mom_sys_output_directory mom_output_file_name

  # 确保 group_name 不为空
  if { ![info exists group_name] || $group_name == "" } {
     MOM_output_literal "(ERROR: group_name is empty or not defined)"
     set group_name "NC_PROGRAM"
  }

  # 确保 operation_name 有默认值
  if { ![info exists operation_name] } {
     set operation_name ""
  }

  # 获取输出目录 (从 NX 获取)
  if { ![info exists mom_sys_output_directory] || $mom_sys_output_directory == "" } {
     set mom_sys_output_directory [MOM_ask_env_var UGII_CAM_OUTPUT_DIR]
     if { $mom_sys_output_directory == "" } {
        set mom_sys_output_directory [file dirname [MOM_ask_env_var UGII_CAM_POST_DIR]]
     }
     # 移除末尾的反斜杠或正斜杠
     set mom_sys_output_directory [string trimright $mom_sys_output_directory "\\/"]
  }

  # 清理组名，移除非法字符
  regsub -all "\[^a-zA-Z0-9_-\]" $group_name "_" group_name

  # 构建完整路径：输出目录/组名/文件名.nc
  set output_path [file join $mom_sys_output_directory $group_name]

  # 创建目录 (如果不存在)
  if { ![file exists $output_path] } {
     if { [catch {file mkdir $output_path} mkdir_err] } {
        MOM_output_literal "(ERROR: Failed to create directory: $output_path - $mkdir_err)"
        # 如果创建失败，使用输出目录本身
        set output_path $mom_sys_output_directory
     }
  }

  # 构建文件名
  if { $operation_name != "" } {
     # 清理操作名中的非法字符
     regsub -all "\[^a-zA-Z0-9_-\]" $operation_name "_" operation_name
     set file_name "${operation_name}.nc"
  } else {
     set file_name "${group_name}.nc"
  }

  set full_path [file join $output_path $file_name]

  # 输出调试信息
  MOM_output_literal "(DEBUG: Output path = $full_path)"

  return $full_path

}


#=============================================================
proc PB_CMD_cancel_suppress_force_once_per_event { } {
#=============================================================
# This command can be called to cancel the effect of
# "MOM_force Once" & "MOM_suppress Once" for each event.
#
# => It's to keep the effect of force & suppress once within
#    the scope of the event that issues the commands and
#    eliminate the unexpected residual effect of such commands
#    that may have been issued by other events.
#
# PB v11.02 -
#
   MOM_cancel_suppress_force_once_per_event
}


#=============================================================
proc PB_CMD_check_zero_tool { } {
#=============================================================
global mom_tool_number

if { $mom_tool_number == 0 } {
          catch { MOM_output_literal "( 【警告】当前刀号为 0，请检查 CAM 刀具设置！ )" }
      }
}


#=============================================================
proc PB_CMD_cleanup_smart_grouping { } {
#=============================================================
# 清理智能分组系统的资源
# 应在 MOM_end_of_program 中调用
#=============================================================
    global ptp_file_name my_last_merged_group_name my_last_group_name
    global my_original_ptp_file_name

    # 关闭当前打开的文件
    catch { MOM_close_output_file $ptp_file_name }

    # 恢复原始的 ptp_file_name（如果有的话）
    if { [info exists my_original_ptp_file_name] } {
        set ptp_file_name $my_original_ptp_file_name
    }

    # 清理状态变量
    catch { unset my_last_merged_group_name }
    catch { unset my_last_group_name }
    catch { unset my_is_merged_op }
    catch { unset my_skip_current_merged_group }
}


#=============================================================
proc PB_CMD_count_group_depth { } {
#=============================================================
# 计算程序组层级深度
# 使用前需设置全局变量: my_temp_group_path
# 输入："TOP/二级目录/DEFAULT"
# 返回：3
#=============================================================
    global my_temp_group_path my_temp_depth
    set parts [split $my_temp_group_path "/"]
    set my_temp_depth [llength $parts]
}


#=============================================================
proc PB_CMD_custom_program_footer { } {
#=============================================================
    # 补充最后一个文件的程序尾
    catch { MOM_output_literal "G05.1 Q0" }
    catch { MOM_output_literal "M05" }
    catch { MOM_output_literal "M09" }
    catch { MOM_output_literal "G40 G49 G80" }
    catch { MOM_output_literal "M30" }
}


#=============================================================
proc PB_CMD_enable_ball_center_output { } {
#=============================================================
# This command can be added to the Start-of-Program event marker
# to enable ball-center output for ANY milling operations that use
# one of the following 3 types (mom_tool_type) of tool:
#  a. "Milling Tool-Ball Mill"
#  b. "Spherical Mill"
#  c. "Milling Tool-5 Parameters" whose tool diameter is 2 times of the corner radius.
#
#  - Only qualified operations will cause NX/Post to produce ball-center outputs.
#  - The condition is verified for every operation.
#  - Ball centers are computed for every move including cutting and non-cutting motions in
#    either standard or turbo process mode.
#  - Legacy command "PB_CMD_center_of_ball_output", if present in the post, will be disabled.
#

   # This command should be called in the Start-of-Program event
   if { ![CALLED_BY "PB_start_of_program"] } {
return
   }

   # This command only works with NX9 & beyond.
   if { [expr [string trim [MOM_ask_env_var UGII_MAJOR_VERSION]] < 9] } {
      CATCH_WARNING "[info level 0] is only functional with NX9 and newer!"
return
   }

   # Disable legacy command
   if { [CMD_EXIST PB_CMD_center_of_ball_output] } {
    uplevel #0 {
      proc PB_CMD_center_of_ball_output { } { }
    }
   }


   # Enable new capability
   global mom_sys_enable_ball_center_output
   set mom_sys_enable_ball_center_output 1


   # Define event handler
   if $mom_sys_enable_ball_center_output {
    uplevel #0 {

      #-------------------------------------------------------------------------------
      proc MOM_ball_center_output { } {
         # This event will be triggered before Start-of-Path when
         # an operation is qualified to produce ball-center outputs.
         #
         # This command may be customized as needed.
         #
      }
      #-------------------------------------------------------------------------------

    }
   }

}


#=============================================================
proc PB_CMD_end_of_alignment_character { } {
#=============================================================
# This command restores sequnece number back to orignal
# This command may be used with the command "PM_CMD_start_of_alignment_character"
#
  global mom_sys_leader saved_seq_num
  if [info exists saved_seq_num] {
    set mom_sys_leader(N) $saved_seq_num
  }
}


#=============================================================
proc PB_CMD_fix_RAPID_SET { } {
#=============================================================
# This command is provided to overwrite the system RAPID_SET
# (defined in ugpost_base.tcl) in order to correct the problem
# with workplane change that doesn't account for +/- directions
# along X or Y principal axis.  It also fixes the problem that
# the First Move was never identified correctly to force
# the output of the 1st point.
#
# The original command has been renamed as ugpost_RAPID_SET.
#
# - This command may be attached to the "Start of Program" event marker.
#
#
# Revisions:
#-----------
# 02-18-08 gsl - Initial version
# 02-26-09 gsl - Used mom_kin_machine_type to derive machine mode when it's UNDEFINED.
# 08-18-15 sws - PR7294525 : Use mom_current_motion to detect first move & initial move
#

  # Only redefine RAPID_SET once, since ugpost_base is only loaded once.
  #
   if { ![CMD_EXIST ugpost_RAPID_SET] } {
      if { [CMD_EXIST RAPID_SET] } {
         rename RAPID_SET ugpost_RAPID_SET
      }
   } else {
return
   }


#***********
uplevel #0 {

#====================
proc RAPID_SET { } {
#====================

   if { [CMD_EXIST PB_CMD_set_principal_axis] } {
      PB_CMD_set_principal_axis
   }


   global mom_cycle_spindle_axis mom_sys_work_plane_change
   global traverse_axis1 traverse_axis2 mom_motion_event mom_machine_mode
   global mom_pos mom_prev_pos mom_from_pos mom_last_pos mom_sys_home_pos
   global mom_sys_tool_change_pos
   global spindle_first rapid_spindle_inhibit rapid_traverse_inhibit
   global mom_current_motion


   if { ![info exists mom_from_pos($mom_cycle_spindle_axis)] && \
         [info exists mom_sys_home_pos($mom_cycle_spindle_axis)] } {

      set mom_from_pos(0) $mom_sys_home_pos(0)
      set mom_from_pos(1) $mom_sys_home_pos(1)
      set mom_from_pos(2) $mom_sys_home_pos(2)

   } elseif { ![info exists mom_sys_home_pos($mom_cycle_spindle_axis)] && \
              [info exists mom_from_pos($mom_cycle_spindle_axis)] } {

      set mom_sys_home_pos(0) $mom_from_pos(0)
      set mom_sys_home_pos(1) $mom_from_pos(1)
      set mom_sys_home_pos(2) $mom_from_pos(2)

   } elseif { ![info exists mom_sys_home_pos($mom_cycle_spindle_axis)] && \
             ![info exists mom_from_pos($mom_cycle_spindle_axis)] } {

      set mom_from_pos(0) 0.0 ; set mom_sys_home_pos(0) 0.0
      set mom_from_pos(1) 0.0 ; set mom_sys_home_pos(1) 0.0
      set mom_from_pos(2) 0.0 ; set mom_sys_home_pos(2) 0.0
   }

   if { ![info exists mom_sys_tool_change_pos($mom_cycle_spindle_axis)] } {
      set mom_sys_tool_change_pos($mom_cycle_spindle_axis) 100000.0
   }


   set is_initial_move [string match "initial_move" $mom_current_motion]
   set is_first_move   [string match "first_move"   $mom_current_motion]

   if { $is_initial_move || $is_first_move } {
      set mom_last_pos($mom_cycle_spindle_axis) $mom_sys_tool_change_pos($mom_cycle_spindle_axis)
   } else {
      if { [info exists mom_last_pos($mom_cycle_spindle_axis)] == 0 } {
         set mom_last_pos($mom_cycle_spindle_axis) $mom_sys_home_pos($mom_cycle_spindle_axis)
      }
   }


   if { $mom_machine_mode != "MILL" && $mom_machine_mode != "DRILL" } {
     # When machine mode is UNDEFINED, ask machine type
      if { ![string match "MILL" [PB_CMD_ask_machine_type]] } {
return
      }
   }


   WORKPLANE_SET

   set rapid_spindle_inhibit  FALSE
   set rapid_traverse_inhibit FALSE


   if { [EQ_is_lt $mom_pos($mom_cycle_spindle_axis) $mom_last_pos($mom_cycle_spindle_axis)] } {
      set going_lower 1
   } else {
      set going_lower 0
   }


   if { ![info exists mom_sys_work_plane_change] } {
      set mom_sys_work_plane_change 1
   }


  # Reverse workplane change direction per spindle axis
   global mom_spindle_axis

   if { [info exists mom_spindle_axis] } {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # User can temporarily disable the work plane change for rapid moves along non-principal
    # spindle axis even when work plane change has been set in the Rapid Move event.
    #
    # Work plane change, if set, will still be in effect for moves along principal axes.
    #
    # - This flag has no effect if the work plane change is not set.
    #

      set disable_non_principal_spindle 0


      switch $mom_cycle_spindle_axis {
         0 {
            if [EQ_is_lt $mom_spindle_axis(0) 0.0] {
               set going_lower [expr abs($going_lower - 1)]
            }
         }
         1 {
            if [EQ_is_lt $mom_spindle_axis(1) 0.0] {
               set going_lower [expr abs($going_lower - 1)]
            }
         }
         2 {
         # Multi-spindle machine
            if [EQ_is_lt $mom_spindle_axis(2) 0.0] {
               set going_lower [expr abs($going_lower - 1)]
            }
         }
      }


     # Per user's choice above, disable work plane change for non-principal spindle axis
     #
      if { $disable_non_principal_spindle } {

         if { ![EQ_is_equal $mom_spindle_axis(0) 1] && \
              ![EQ_is_equal $mom_spindle_axis(1) 1] && \
              ![EQ_is_equal $mom_spindle_axis(0) 1] } {

            global mom_user_work_plane_change
            global mom_user_spindle_first

            set mom_user_work_plane_change $mom_sys_work_plane_change
            set mom_sys_work_plane_change 0

            if [info exists spindle_first] {
               set mom_user_spindle_first $spindle_first
            } else {
               set mom_user_spindle_first NONE
            }
         }
      }
   }


   if { $mom_sys_work_plane_change } {

      if { $going_lower } {
         set spindle_first FALSE
      } else {
         set spindle_first TRUE
      }

     # Force output in Initial Move and First Move.
      if { !$is_initial_move && !$is_first_move } {

         if { [EQ_is_equal $mom_pos($mom_cycle_spindle_axis) $mom_last_pos($mom_cycle_spindle_axis)] } {
            set rapid_spindle_inhibit TRUE
         } else {
            set rapid_spindle_inhibit FALSE
         }

         if { [EQ_is_equal $mom_pos($traverse_axis1) $mom_prev_pos($traverse_axis1)] && \
              [EQ_is_equal $mom_pos($traverse_axis2) $mom_prev_pos($traverse_axis2)] && \
              [EQ_is_equal $mom_pos(3) $mom_prev_pos(3)] && [EQ_is_equal $mom_pos(4) $mom_prev_pos(4)] } {

            set rapid_traverse_inhibit TRUE
         } else {
            set rapid_traverse_inhibit FALSE
         }
      }

   } else {
      set spindle_first NONE
   }

} ;# RAPID_SET

} ;# uplevel
#***********
}


#=============================================================
proc PB_CMD_get_group_hierarchy { } {
#=============================================================
# 获取当前操作的完整程序组层级路径
# 返回格式：如 "TOP/二级目录"
#=============================================================
    global mom_group_name my_group_level_map

    set hierarchy [list]
    set current_group $mom_group_name

    # 沿着 parent 链向上追溯
    while { $current_group != "" && $current_group != "NC_PROGRAM" } {
        lappend hierarchy $current_group
        if { [info exists my_group_level_map($current_group)] } {
            set current_group $my_group_level_map($current_group)
        } else {
            break
        }
    }

    # 反转列表得到从根到叶的顺序
    set hierarchy [lreverse $hierarchy]
    return [join $hierarchy "/"]
}


#=============================================================
proc PB_CMD_get_parent_group { } {
#=============================================================
# 获取父级程序组名称
# 使用前需设置全局变量: my_temp_group_path
# 输入："TOP/二级目录/DEFAULT"
# 返回："二级目录"
#=============================================================
    global my_temp_group_path my_temp_parent_group
    set parts [split $my_temp_group_path "/"]
    if { [llength $parts] >= 2 } {
        set my_temp_parent_group [lindex $parts end-1]
    } else {
        set my_temp_parent_group [lindex $parts 0]
    }
}


#=============================================================
proc PB_CMD_get_parent_group_name { } {
#=============================================================
# 获取父程序组名称 (简化版本)
# 实际项目中可能需要通过 NX Open API 获取
#
  # 这里简化处理，假设组名包含层级信息
  # 例如：RIGHT 是 TOP 的子组，组名可能是 "TOP\\RIGHT"

  global mom_group_name

  if { [info exists mom_group_name] && [string match "*\\*" $mom_group_name] } {
     # 包含反斜杠，说明是子组
     set parts [split $mom_group_name "\\"]
     if { [llength $parts] >= 2 } {
        return [lindex $parts end-1]
     }
  }

  return ""
}


#=============================================================
proc PB_CMD_handle_sync_event { } {
#=============================================================
  global mom_sync_code
  global mom_sync_index
  global mom_sync_start
  global mom_sync_incr
  global mom_sync_max


  set mom_sync_start     99
  set mom_sync_incr       1
  set mom_sync_max    199


  if {![info exists mom_sync_code] } {
    set mom_sync_code $mom_sync_start
  }

  set mom_sync_code [expr $mom_sync_code + $mom_sync_incr]

  MOM_do_template sync_code
}


#=============================================================
proc PB_CMD_init_helix { } {
#=============================================================
uplevel #0 {
#
# This ommand will be executed automatically at the start of program and
# anytime it is loaded as a slave post of a linked post.
#
# This procedure can be used to enable your post to output helix.
# You can choose from the following options to format the circle
# block template to output the helix parameters.
#

   set mom_sys_helix_pitch_type    "rise_radian"

#
# The default setting for mom_sys_helix_pitch_type is "rise_radian".
# This is the most common.  Other choices are:
#
#    "rise_radian"              Measures the rise over one radian.
#    "rise_revolution"          Measures the rise over 360 degrees.
#    "none"                     Will suppress the output of pitch.
#    "other"                    Allows you to calculate the pitch
#                               using your own formula.
#
# This custom command uses the block template circular_move to output
# the helix block.  If your post uses a block template with a different
# name, you must edit the line that outputs the helix block.

#
#  The following variable deines the output mode for helical records.
#
#  FULL_CIRCLE  -- This mode will output a helix record for each 360
#                  degrees of the helix.
#  QUADRANT  --    This mode will output a helix record for each 90
#                  degrees of the helix.
#  LINEAR  --      This mode will output the entire helix as linear gotos.
#  END_POINT --    This mode will assume the control can define an entire
#                  helix in a single block.

   set mom_kin_helical_arc_output_mode FULL_CIRCLE

   MOM_reload_kinematics


#=============================================================
proc MOM_helix_move { } {
#=============================================================
   global mom_pos_arc_plane
   global mom_sys_cir_vector
   global mom_sys_helix_pitch_type
   global mom_helix_pitch
   global mom_prev_pos mom_pos_arc_center
   global PI


   switch $mom_pos_arc_plane {
      XY { MOM_suppress once K ; set cir_index 2 }
      YZ { MOM_suppress once I ; set cir_index 0 }
      ZX { MOM_suppress once J ; set cir_index 1 }
   }

   switch $mom_sys_helix_pitch_type {
      none { }
      rise_revolution { set pitch $mom_helix_pitch }
      rise_radian { set pitch [expr $mom_helix_pitch / ($PI * 2.0)]}
      other {
#
#    Place your custom helix pitch code here
#
      }
      default { set mom_sys_helix_pitch_type "none" }
   }

   MOM_force once X Y Z

   if { [string compare "none" $mom_sys_helix_pitch_type] } {
  #    MOM_force once I J K

     #<08-01-06 gsl>
      switch $mom_sys_cir_vector {
         "Vector - Arc Center to Start" {
            set mom_prev_pos($cir_index) $pitch
            set mom_pos_arc_center($cir_index) 0.0
         }
         "Vector - Arc Start to Center" -
         "Unsigned Vector - Arc Start to Center" {
            set mom_prev_pos($cir_index) 0.0
            set mom_pos_arc_center($cir_index) $pitch
         }
         "Vector - Absolute Arc Center" {
            set mom_pos_arc_center($cir_index) $pitch
         }
      }
   }

#
# You may need to edit this line if you output more than one block
# or if you have changed the name of your circular_move block template
#
   MOM_do_template circular_move
}

} ;# uplevel

}


#=============================================================
proc PB_CMD_init_smart_grouping { } {
#=============================================================
# 初始化智能分组系统的全局变量和拦截器
# 应在 MOM_start_of_program 中调用
#=============================================================
    global my_out_dir my_group_level_map my_valid_files ptp_file_name
    global my_original_ptp_file_name

    # 保存原始的 ptp_file_name，防止 NX 记住被我们修改过的路径
    if { [info exists ptp_file_name] } {
        set my_original_ptp_file_name $ptp_file_name
    }

    # 1. 锁定真正的根目录 (例如 D:\...\NC)
    if { [info exists ptp_file_name] && $ptp_file_name != "" } {
        set temp_dir [file dirname [file nativename $ptp_file_name]]
        # 剥离可能因为 NX 记忆而残留的子目录，找到真正的根目录
        while {1} {
            set tail [file tail $temp_dir]
            if { $tail == "DEFAULT" || $tail == "二级目录处理成单一NC文件" || [regexp {^(TOP|LEFT|RIGHT|RIG|LEF).*} $tail] } {
                set temp_dir [file dirname $temp_dir]
            } else {
                break
            }
        }
        set my_out_dir $temp_dir
    } else {
        catch { set my_out_dir [file nativename [MOM_ask_env_var UGII_CAM_OUTPUT_DIR]] }
    }

    catch { unset my_group_level_map }
    array set my_group_level_map {}
    set my_valid_files [list]

    # 挂载 MOM_start_of_group 拦截器，维护层级映射表和组栈
    if { [llength [info commands MOM_start_of_group]] && ![llength [info commands MOM_start_of_group_orig]] } {
        rename MOM_start_of_group MOM_start_of_group_orig
        proc MOM_start_of_group { } {
            global mom_group_name mom_parent_group_name my_group_level_map my_group_stack
            if { ![info exists my_group_stack] } { set my_group_stack [list] }

            set gname ""
            catch { set gname $mom_group_name }
            if { $gname == "" } { catch { set gname [MOM_ask_group_name] } }

            set pname ""
            catch { set pname $mom_parent_group_name }

            if { $gname != "" } {
                set my_group_level_map($gname) $pname

                # 检查父组是否在栈中，以处理平级组或根组切换
                if { $pname != "" && $pname != "NC_PROGRAM" && $pname != "PROGRAM" } {
                    set idx [lsearch -exact $my_group_stack $pname]
                    if { $idx != -1 } {
                        # 父组在栈中，截断栈到父组位置
                        set my_group_stack [lrange $my_group_stack 0 $idx]
                    } else {
                        # 父组不在栈中，说明父组被漏掉了（通常是因为用户直接选中了根节点后处理）
                        # 我们需要将父组补入栈中
                        set my_group_stack [list $pname]
                    }
                } else {
                    # 根目录组，清空栈
                    set my_group_stack [list]
                }

                lappend my_group_stack $gname
            }
            catch { MOM_start_of_group_orig }
        }
    }

    # 挂载 MOM_end_of_group 拦截器，维护组栈
    if { ![llength [info commands MOM_end_of_group]] } {
        proc MOM_end_of_group { } {
            global my_group_stack
            if { [info exists my_group_stack] && [llength $my_group_stack] > 0 } {
                set popped [lindex $my_group_stack end]
                set my_group_stack [lreplace $my_group_stack end end]
            }
        }
    } else {
        if { ![llength [info commands MOM_end_of_group_orig]] } {
            rename MOM_end_of_group MOM_end_of_group_orig
            proc MOM_end_of_group { } {
                global my_group_stack
                if { [info exists my_group_stack] && [llength $my_group_stack] > 0 } {
                    set popped [lindex $my_group_stack end]
                    set my_group_stack [lreplace $my_group_stack end end]
                }
                catch { MOM_end_of_group_orig }
            }
        }
    }

    # 挂载拦截器，在每次下刀前执行文件判断（完全接管文件控制）
    if { [llength [info commands MOM_start_of_path]] && ![llength [info commands MOM_start_of_path_orig]] } {
        rename MOM_start_of_path MOM_start_of_path_orig
        proc MOM_start_of_path { } {
            global my_is_merged_op mom_operation_name mom_tool_name my_skip_current_merged_group

            # 1. 先执行我们的智能文件切换逻辑
            catch { PB_CMD_smart_file_switch }

            # 1.5 针对二级程序组（合并输出），在每个工序开头输出明显的分割注释
            if { [info exists my_is_merged_op] && $my_is_merged_op == 1 } {
                if { ![info exists my_skip_current_merged_group] || $my_skip_current_merged_group == 0 } {
                    # 检查是否启用了工序分隔注释
                    global my_output_operation_separator
                    if { ![info exists my_output_operation_separator] || $my_output_operation_separator == 1 } {
                        catch {
                            global mom_my_op_tool_str
                            set mom_my_op_tool_str ""
                            if { [info exists mom_tool_name] } {
                                set mom_my_op_tool_str "( --- TOOL      : $mom_tool_name --- )"
                            }
                            catch { MOM_output_literal "( )" }
                            catch { MOM_output_literal "( ************************************************** )" }
                            catch { MOM_output_literal "( --- OPERATION : $mom_operation_name --- )" }
                            if { $mom_my_op_tool_str != "" } { catch { MOM_output_literal "$mom_my_op_tool_str" } }
                            catch { MOM_output_literal "( ************************************************** )" }
                            catch { MOM_output_literal "( )" }
                        }
                    }
                }
            }

            # 2. 再调用原始的下刀逻辑，确保机床状态、刀具等正常初始化
            catch { MOM_start_of_path_orig }
        }
    }

    # 挂载 MOM_end_of_program 拦截器，确保最后一个文件有程序尾，并执行清理
    # (已移除，改为在 Post Builder 中添加 PB_CMD_custom_program_footer)
}


#=============================================================
proc PB_CMD_kin_abort_event { } {
#=============================================================
   if { [CMD_EXIST PB_CMD_abort_event] } {
      PB_CMD_abort_event
   }
}


#=============================================================
proc PB_CMD_kin_before_motion { } {
#=============================================================
}


#=============================================================
proc PB_CMD_kin_before_output { } {
#=============================================================
# Broker command ensuring PB_CMD_before_output, if present, gets executed
# by MOM_before_output.
#
# ==> DO NOT add anything here!
# ==> All customization must be done in PB_CMD_before_output!
# ==> PB_CMD_before_output MUST NOT call any "MOM_output" commands!
#
   if { [CMD_EXIST PB_CMD_before_output] } {
      PB_CMD_before_output
   }
}


#=============================================================
proc PB_CMD_kin_end_of_path { } {
#=============================================================
  # Record tool time for this operation.
   if { [CMD_EXIST PB_CMD_set_oper_tool_time] } {
      PB_CMD_set_oper_tool_time
   }

  # Clear tool holder angle used in operation
   global mom_use_b_axis
   UNSET_VARS mom_use_b_axis
}


#=============================================================
proc PB_CMD_kin_feedrate_set { } {
#=============================================================
# This command supercedes the functionalites provided by the
# FEEDRATE_SET in ugpost_base.tcl.  Post Builder automatically
# generates proper call sequences to this command in the
# Event handlers.
#
# This command must be used in conjunction with ugpost_base.tcl.
#
   global   feed com_feed_rate
   global   mom_feed_rate_output_mode super_feed_mode feed_mode
   global   mom_cycle_feed_rate_mode mom_cycle_feed_rate
   global   mom_cycle_feed_rate_per_rev
   global   mom_motion_type
   global   Feed_IPM Feed_IPR Feed_MMPM Feed_MMPR Feed_INV
   global   mom_sys_feed_param
   global   mom_sys_cycle_feed_mode


   set super_feed_mode $mom_feed_rate_output_mode

   set f_pm [ASK_FEEDRATE_FPM]
   set f_pr [ASK_FEEDRATE_FPR]


  #<12-16-2014 gsl> To determine feed mode for RETRACT per motion type
   global mom_motion_event
   if { ![info exists mom_motion_event] } {
      set mom_motion_event UNDEFINED
   }

   set feed_type RAPID


   switch $mom_motion_type {

      CYCLE {
         if { [info exists mom_sys_cycle_feed_mode] } {
            if { [string compare "Auto" $mom_sys_cycle_feed_mode] } {
               set mom_cycle_feed_rate_mode $mom_sys_cycle_feed_mode
            }
         }
         if { [info exists mom_cycle_feed_rate_mode] }    { set super_feed_mode $mom_cycle_feed_rate_mode }
         if { [info exists mom_cycle_feed_rate] }         { set f_pm $mom_cycle_feed_rate }
         if { [info exists mom_cycle_feed_rate_per_rev] } { set f_pr $mom_cycle_feed_rate_per_rev }
      }

      FROM -
      RETURN -
      LIFT -
      TRAVERSAL -
      GOHOME -
      GOHOME_DEFAULT -
      RAPID {
        #<Sep-07-2016 gsl>
        # SUPER_FEED_MODE_SET RAPID
         if { [string match "linear_move"   $mom_motion_event] ||\
              [string match "circular_move" $mom_motion_event] } {
            set feed_type CONTOUR
         }
      }

      default {
        #<Sep-07-2016 gsl>
         if { !([EQ_is_zero $f_pm] && [EQ_is_zero $f_pr]) } {
            set feed_type CONTOUR
         }
      }
   }

  #<Sep-07-2016 gsl>
   if { ![string match "CYCLE" $mom_motion_type] } {
      SUPER_FEED_MODE_SET $feed_type
   }


  # Treat RETRACT as cutting when specified
   global mom_sys_retract_feed_mode
   if { [string match "RETRACT" $mom_motion_type] } {

      if { [info exist mom_sys_retract_feed_mode] && [string match "CONTOUR" $mom_sys_retract_feed_mode] } {
         if { !([EQ_is_zero $f_pm] && [EQ_is_zero $f_pr]) } {
            SUPER_FEED_MODE_SET CONTOUR
         }
      }
   }


   set feed_mode $super_feed_mode


  # Adjust feedrate format per Post output unit again.
   global mom_kin_output_unit
   if { ![string compare "IN" $mom_kin_output_unit] } {
      switch $feed_mode {
         MMPM {
            set feed_mode "IPM"
            CATCH_WARNING "Feedrate mode MMPM changed to IPM"
         }
         MMPR {
            set feed_mode "IPR"
            CATCH_WARNING "Feedrate mode MMPR changed to IPR"
         }
      }
   } else {
      switch $feed_mode {
         IPM {
            set feed_mode "MMPM"
            CATCH_WARNING "Feedrate mode IPM changed to MMPM"
         }
         IPR {
            set feed_mode "MMPR"
            CATCH_WARNING "Feedrate mode IPR changed to MMPR"
         }
      }
   }


   switch $feed_mode {
      IPM     -
      MMPM    { set feed $f_pm }
      IPR     -
      MMPR    { set feed $f_pr }
      DPM     { set feed [PB_CMD_FEEDRATE_DPM] }
      FRN     -
      INVERSE { set feed [PB_CMD_FEEDRATE_NUMBER] }
      default {
         CATCH_WARNING "INVALID FEED RATE MODE"
         return
      }
   }


  # Post Builder provided format for the current mode:
   if { [info exists mom_sys_feed_param(${feed_mode},format)] } {
      MOM_set_address_format F $mom_sys_feed_param(${feed_mode},format)
   } else {
      switch $feed_mode {
         IPM     -
         MMPM    -
         IPR     -
         MMPR    -
         DPM     -
         FRN     { MOM_set_address_format F Feed_${feed_mode} }
         INVERSE { MOM_set_address_format F Feed_INV }
      }
   }


  # Commentary output
   set com_feed_rate $f_pm


  # Execute user's command, if any.
   if { [CMD_EXIST PB_CMD_FEEDRATE_SET] } {
      PB_CMD_FEEDRATE_SET
   }
}


#=============================================================
proc PB_CMD_kin_handle_sync_event { } {
#=============================================================
  PB_CMD_handle_sync_event
}


#=============================================================
proc PB_CMD_kin_init_new_iks { } {
#=============================================================
   global mom_kin_machine_type
   global mom_new_iks_exists

  # Revert legacy dual-head kinematic parameters when new IKS is absent.
   if { [string match "5_axis_dual_head" $mom_kin_machine_type] } {
      if { ![info exists mom_new_iks_exists] } {
         set ugii_version [string trim [MOM_ask_env_var UGII_VERSION]]
         if { ![string match "v3" $ugii_version] } {

            if { [CMD_EXIST PB_CMD_revert_dual_head_kin_vars] } {
               PB_CMD_revert_dual_head_kin_vars
            }
return
         }
      }
   }

  # Initialize new IKS parameters.
   if { [CMD_EXIST PB_init_new_iks] } {
      PB_init_new_iks
   }

  # Users can provide next command to modify or disable new IKS options.
   if { [CMD_EXIST PB_CMD_revise_new_iks] } {
      PB_CMD_revise_new_iks
   }

  # Revert legacy dual-head kinematic parameters when new IKS is disabled.
   if { [string match "5_axis_dual_head" $mom_kin_machine_type] } {
      global mom_kin_iks_usage
      if { $mom_kin_iks_usage == 0 } {
         if { [CMD_EXIST PB_CMD_revert_dual_head_kin_vars] } {
            PB_CMD_revert_dual_head_kin_vars
         }
      }
   }
}


#=============================================================
proc PB_CMD_kin_init_probing_cycles { } {
#=============================================================
   set cmd PB_CMD_init_probing_cycles
   if { [CMD_EXIST "$cmd"] } {
      eval $cmd
   }
}


#=============================================================
proc PB_CMD_kin_set_csys { } {
#=============================================================
# - For mill post -
#

  # Output NC code according to CSYS
   if { [CMD_EXIST PB_CMD_set_csys] } {
      PB_CMD_set_csys
   }

  # Overload IKS params from machine model.
   PB_CMD_reload_iks_parameters

  # In case Axis Rotation has been set to "reverse"
   if { [CMD_EXIST PB_CMD_reverse_rotation_vector] } {
      PB_CMD_reverse_rotation_vector
   }
}


#=============================================================
proc PB_CMD_kin_start_of_path { } {
#=============================================================
# - For mill post -
#
#  This command is executed at the start of every operation.
#  It will verify if a new head (post) was loaded and will
#  then initialize any functionality specific to that post.
#
#  It will also restore the master Start of Program &
#  End of Program event handlers.
#
#  --> DO NOT CHANGE THIS COMMAND UNLESS YOU KNOW WHAT YOU ARE DOING.
#  --> DO NOT CALL THIS COMMAND FROM ANY OTHER CUSTOM COMMAND.
#
  global mom_sys_head_change_init_program

   if { [info exists mom_sys_head_change_init_program] } {

      PB_CMD_kin_start_of_program
      unset mom_sys_head_change_init_program


     # Load alternate units' parameters
      if [CMD_EXIST PB_load_alternate_unit_settings] {
         PB_load_alternate_unit_settings
         rename PB_load_alternate_unit_settings ""
      }


     # Execute start of head callback in new post's context.
      global CURRENT_HEAD
      if { [info exists CURRENT_HEAD] && [CMD_EXIST PB_start_of_HEAD__$CURRENT_HEAD] } {
         PB_start_of_HEAD__$CURRENT_HEAD
      }

     # Restore master start & end of program handlers
      if { [CMD_EXIST "MOM_start_of_program_save"] } {
         if { [CMD_EXIST "MOM_start_of_program"] } {
            rename MOM_start_of_program ""
         }
         rename MOM_start_of_program_save MOM_start_of_program
      }
      if { [CMD_EXIST "MOM_end_of_program_save"] } {
         if { [CMD_EXIST "MOM_end_of_program"] } {
            rename MOM_end_of_program ""
         }
         rename MOM_end_of_program_save MOM_end_of_program
      }

     # Restore master head change event handler
      if { [CMD_EXIST "MOM_head_save"] } {
         if { [CMD_EXIST "MOM_head"] } {
            rename MOM_head ""
         }
         rename MOM_head_save MOM_head
      }
   }

  # Overload IKS params from machine model.
   PB_CMD_reload_iks_parameters

  # Incase Axis Rotation has been set to "reverse"
   if { [CMD_EXIST PB_CMD_reverse_rotation_vector] } {
      PB_CMD_reverse_rotation_vector
   }

  # Initialize tool time accumulator for this operation.
   if { [CMD_EXIST PB_CMD_init_oper_tool_time] } {
      PB_CMD_init_oper_tool_time
   }

  # Force out motion G code at the start of path.
   MOM_force once G_motion
}


#=============================================================
proc PB_CMD_kin_start_of_program { } {
#=============================================================
#  This command will execute the following custom commands for
#  initialization.  They will be executed once at the start of
#  program and again each time they are loaded as a linked post.
#  After execution they will be deleted so that they are not
#  present when a different post is loaded.  You may add a call
#  to any command that you want executed when a linked post is
#  loaded.
#
#  Note when a linked post is called in, the Start of Program
#  event marker is not executed again.
#
#  --> DO NOT REMOVE ANY LINES FROM THIS PROCEDURE UNLESS YOU KNOW
#      WHAT YOU ARE DOING.
#  --> DO NOT CALL THIS PROCEDURE FROM ANY
#      OTHER CUSTOM COMMAND.
#
   global mom_kin_machine_type


   set command_list [list]

   if { [info exists mom_kin_machine_type] } {
      if { ![string match "*3_axis_mill*" $mom_kin_machine_type] &&\
           ![string match "*lathe*" $mom_kin_machine_type] } {

         lappend command_list  PB_CMD_kin_init_rotary
      }
   }

   lappend command_list  PB_CMD_kin_init_new_iks

   lappend command_list  PB_CMD_init_pivot_offsets
   lappend command_list  PB_CMD_init_auto_retract
   lappend command_list  PB_CMD_initialize_parallel_zw_mode
   lappend command_list  PB_CMD_init_parallel_zw_mode
   lappend command_list  PB_CMD_initialize_tool_list
   lappend command_list  PB_CMD_init_tool_list
   lappend command_list  PB_CMD_init_tape_break
   lappend command_list  PB_CMD_initialize_spindle_axis
   lappend command_list  PB_CMD_init_spindle_axis
   lappend command_list  PB_CMD_initialize_helix
   lappend command_list  PB_CMD_init_helix
   lappend command_list  PB_CMD_pq_cutcom_initialize
   lappend command_list  PB_CMD_init_pq_cutcom
   lappend command_list  PB_CMD_init_smart_grouping

   lappend command_list  PB_CMD_kin_init_probing_cycles

   lappend command_list  PB_DEFINE_MACROS

   if { [info exists mom_kin_machine_type] } {
      if { [string match "*3_axis_mill_turn*" $mom_kin_machine_type] } {

         lappend command_list  PB_CMD_kin_init_mill_xzc
         lappend command_list  PB_CMD_kin_mill_xzc_init
         lappend command_list  PB_CMD_kin_init_mill_turn
         lappend command_list  PB_CMD_kin_mill_turn_initialize
      }
   }


   foreach cmd $command_list {

      if { [CMD_EXIST "$cmd"] } {

        # <PB v2.0.2>
        # Old init commands for XZC/MILL_TURN posts are not executed.
        # Parameters set by these commands in the v2.0 legacy posts
        # will need to be transfered to PB_CMD_init_mill_xzc &
        # PB_CMD_init_mill_turn commands respectively.

         switch $cmd {
            "PB_CMD_kin_mill_xzc_init" -
            "PB_CMD_kin_mill_turn_initialize" {}
            default { eval $cmd }
         }
         rename $cmd ""
         proc $cmd { args } {}
      }
   }
}


#=============================================================
proc PB_CMD_negate_R_value { } {
#=============================================================
# This command negates the value of radius when the included angle
# of an arc is greater than 180.
#
# ==> This comamnd may be added to the Circular Move event for a post
#     of Fanuc controller when the R-style circular output format is used.
#
# 10-05-11 gsl - (pb801 IR2178985) Initial version
#

   global mom_arc_angle mom_arc_radius

   if [expr $mom_arc_angle > 180.0] {
      set mom_arc_radius [expr -1*$mom_arc_radius]
   }
}


#=============================================================
proc PB_CMD_output_file_header { } {
#=============================================================
# 输出文件头部信息（包含工具信息、日期等）
# 使用前需设置全局变量: my_temp_group_name
#=============================================================
    global my_temp_group_name
    global my_include_date_in_header my_include_tool_details
    global my_include_stock_info my_include_z_min_info
    global mom_date mom_tool_name mom_stock_part_number

    # 输出日期
    if { ![info exists my_include_date_in_header] || $my_include_date_in_header == 1 } {
        catch { MOM_output_literal "( Generated on: $mom_date )" }
    }

    # 输出程序组名称
    catch { MOM_output_literal "( )" }
    catch { MOM_output_literal "( ================================================ )" }
    catch { MOM_output_literal "( Program Group: $my_temp_group_name )" }
    catch { MOM_output_literal "( ================================================ )" }
    catch { MOM_output_literal "( )" }

    # 输出刀具信息
    if { (![info exists my_include_tool_details] || $my_include_tool_details == 1) && [info exists mom_tool_name] } {
        catch { MOM_output_literal "( Tool: $mom_tool_name )" }
    }

    # 输出毛坯信息
    if { (![info exists my_include_stock_info] || $my_include_stock_info == 1) && [info exists mom_stock_part_number] } {
        catch { MOM_output_literal "( Stock: $mom_stock_part_number )" }
    }

    catch { MOM_output_literal "( )" }
}


#=============================================================
proc PB_CMD_pause { } {
#=============================================================
# This command enables you to pause the UG/Post processing.
#
  PAUSE
}


#=============================================================
proc PB_CMD_program_header { } {
#=============================================================
    global mom_date
    global mom_tool_name mom_tool_diameter mom_tool_corner1_radius mom_tool_lower_corner_radius
    global mom_tool_nose_radius mom_tool_profile_radius
    global mom_tool_adjust_register mom_cutcom_adjust_register
    global mom_stock_part mom_stock_floor
    global mom_operation_name mom_group_name current_output_file
    global mom_tool_minimum_length mom_tool_holder_libref

    set prog_name "UNKNOWN"
    if { [info exists current_output_file] && $current_output_file != "" } {
        set prog_name [file rootname [file tail $current_output_file]]
    } elseif { [info exists mom_operation_name] } {
        set prog_name $mom_operation_name
    } elseif { [info exists mom_group_name] } {
        set prog_name $mom_group_name
    }

    set date_str ""
    catch { set date_str $mom_date }

    set t_name "UNKNOWN"
    catch { set t_name $mom_tool_name }

    set t_dia "0.0"
    catch { set t_dia [format "%.1f" $mom_tool_diameter] }

    set t_cr "0.0"
    if { [info exists mom_tool_lower_corner_radius] } {
        catch { set t_cr [format "%.1f" $mom_tool_lower_corner_radius] }
    } elseif { [info exists mom_tool_nose_radius] } {
        catch { set t_cr [format "%.1f" $mom_tool_nose_radius] }
    } elseif { [info exists mom_tool_profile_radius] } {
        catch { set t_cr [format "%.1f" $mom_tool_profile_radius] }
    } else {
        catch { set t_cr [format "%.1f" $mom_tool_corner1_radius] }
    }

    set t_min_len "0.00"
    catch { set t_min_len [format "%.2f" $mom_tool_minimum_length] }

    set t_holder_lib "NONE"
    catch { set t_holder_lib $mom_tool_holder_libref }

    set h_reg "00"
    catch { set h_reg [format "%02d" $mom_tool_adjust_register] }

    set d_reg "00"
    catch { set d_reg [format "%02d" $mom_cutcom_adjust_register] }

    set stock_p "0.000"
    catch { set stock_p [format "%.3f" $mom_stock_part] }

    set stock_f "0.000"
    catch { set stock_f [format "%.3f" $mom_stock_floor] }

    global mom_my_prog_name mom_my_date_str mom_my_tool_name mom_my_dia mom_my_cr mom_my_min_len mom_my_holder mom_my_h_reg mom_my_d_reg mom_my_stock_p mom_my_stock_f mom_my_z_min
    set mom_my_prog_name $prog_name
    set mom_my_date_str $date_str
    set mom_my_tool_name $t_name
    set mom_my_dia $t_dia
    set mom_my_cr $t_cr
    set mom_my_min_len $t_min_len
    set mom_my_holder $t_holder_lib
    set mom_my_h_reg $h_reg
    set mom_my_d_reg $d_reg
    set mom_my_stock_p $stock_p
    set mom_my_stock_f $stock_f

    # 进阶建议一：程序头增加“Z轴最低深度”预估
    global mom_z_min
    set z_min [expr {[info exists mom_z_min] ? $mom_z_min : 0.0}]
    set mom_my_z_min [format "%.3f" $z_min]

    # 新增：程序头强制 Z 轴回零，防止个别情况撞刀
    catch { MOM_output_literal "(PROGRAM: $mom_my_prog_name)" }
    catch { MOM_output_literal "(DATE: $mom_my_date_str)" }
    catch { MOM_output_literal "(TOOL: $mom_my_tool_name)" }
    catch { MOM_output_literal "(DIA: $mom_my_dia | CR: $mom_my_cr)" }
    catch { MOM_output_literal "(MIN LENGTH: $mom_my_min_len | HOLDER: $mom_my_holder)" }
    catch { MOM_output_literal "(COMP: H$mom_my_h_reg | D$mom_my_d_reg)" }
    catch { MOM_output_literal "(STOCK: XY $mom_my_stock_p MM | Z $mom_my_stock_f MM)" }
    catch { MOM_output_literal "(Z-MIN: $mom_my_z_min MM)" }
    # catch { MOM_output_literal "G91 G28 Z0.0" } ;# 注释掉，防止与 tool_change 重复输出
}


#=============================================================
proc PB_CMD_record_parent_group { } {
#=============================================================
# Record operation parent group
   global mom_operation_name mom_group_name my_group_level_map
   if { [info exists mom_operation_name] && $mom_operation_name != "" } {
       set gname ""
       catch { set gname $mom_group_name }
       if { $gname == "" } { catch { set gname [MOM_ask_group_name] } }
       if { $gname != "" && $gname != $mom_operation_name } {
           set my_group_level_map($mom_operation_name) $gname
       }
   }
}


#=============================================================
proc PB_CMD_reload_iks_parameters { } {
#=============================================================
# This command overloads new IKS params from a machine model.(NX4)
# It will be executed automatically at the start of each path
# or when CSYS has changed.
#
   global mom_csys_matrix
   global mom_kin_iks_usage

  #----------------------------------------------------------
  # Set a classification to fetch kinematic parameters from
  # a particular set of K-components of a machine.
  # - Default is NONE.
  #----------------------------------------------------------
   set custom_classification NONE

   if { [info exists mom_kin_iks_usage] && $mom_kin_iks_usage == 1 } {
      if [info exists mom_csys_matrix] {
         if [llength [info commands MOM_validate_machine_model] ] {
            if { [MOM_validate_machine_model] == "TRUE" } {
               MOM_reload_iks_parameters "$custom_classification"
               MOM_reload_kinematics
            }
         }
      }
   }
}


#=============================================================
proc PB_CMD_restore_work_plane_change { } {
#=============================================================
#<02-18-08 gsl> Restore work plane change flag, if being disabled due to a simulated cycle.

   global mom_user_work_plane_change mom_sys_work_plane_change
   global mom_user_spindle_first spindle_first

   if { [info exists mom_user_work_plane_change] } {
      set mom_sys_work_plane_change $mom_user_work_plane_change
      set spindle_first $mom_user_spindle_first
      unset mom_user_work_plane_change
      unset mom_user_spindle_first
   }
}


#=============================================================
proc PB_CMD_revise_new_iks { } {
#=============================================================
# This command is executed automatically, which allows you
# to change the default IKS parameters or disable the IKS
# service completely.
#
# *** Do not attach this command to any event marker! ***
#
   global mom_kin_iks_usage
   global mom_kin_rotary_axis_method
   global mom_kin_spindle_axis
   global mom_kin_4th_axis_vector
   global mom_kin_5th_axis_vector


  # Uncomment next statement to disable new IKS service
  # set mom_kin_iks_usage           0


  # Uncomment next statement to change rotary solution method
  # set mom_kin_rotary_axis_method  "ZERO"


  # Uncomment next statement, if any parameter above has changed.
  # MOM_reload_kinematics
}


#=============================================================
proc PB_CMD_run_postprocess { } {
#=============================================================
# This is an example showing how MOM_run_postprocess can be used.
# It can be called in the Start of Program event (or anywhere)
# to process the same objects being posted using a secondary post.
#
# ==> It's advisable NOT to use the active post and the same
#     output file for this secondary posting job.
# ==> Ensure legitimate and fully qualified file path for post processor and
#     the output file are specified (in platform convention) for the command.
#

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# CAUTION - Comment out next line to activate this function!
return
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   MOM_run_postprocess "[file dirname $::mom_event_handler_file_name]/MORI_HORI_Sub.tcl"\
                       "[file dirname $::mom_event_handler_file_name]/MORI_HORI_Sub.def"\
                       "${::mom_output_file_directory}sub_program.out"
}


#=============================================================
proc PB_CMD_sanitize_filename { } {
#=============================================================
# 清理文件名，移除非法字符
# 使用前需设置全局变量: my_temp_filename
#=============================================================
    global my_temp_filename my_temp_clean_filename
    # 替换空格为下划线
    set clean [string map {" " "_" ":" "_" "/" "_"} $my_temp_filename]
    # 移除非字母数字字符（保留中文、下划线、连字符）
    regsub -all {[^a-zA-Z0-9_\-\u4e00-\u9fa5]} $clean "" clean
    set my_temp_clean_filename $clean
}


#=============================================================
proc PB_CMD_set_csys { } {
#=============================================================
# This custom command is provided as the default to nullify
# the same command in a linked post that may have been
# imported from pb_cmd_coordinate_system_rotation.tcl.
#
}


#=============================================================
proc PB_CMD_set_cycle_plane { } {
#=============================================================
# Use this command to determine and output proper plane code
# when G17/18/19 is used in the cycle definition.
#


 #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 # This option can be set to 1, if the address of cycle's
 # principal axis needs to be suppressed. (Ex. siemens controller)
 #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  set suppress_principal_axis 0


 #++++++++++++++++++++++++++++++++++++++++++++++++++++++
 # This option can be set to 1, if the plane code needs
 # to be forced out @ the start of every set of cycles.
 #++++++++++++++++++++++++++++++++++++++++++++++++++++++
  set force_plane_code 0


  global mom_kin_machine_type
  global mom_kin_4th_axis_type mom_kin_4th_axis_plane
  global mom_kin_5th_axis_type
  global mom_tool_axis mom_sys_spindle_axis mom_kin_spindle_axis
  global mom_pos
  global mom_cycle_spindle_axis mom_cutcom_plane mom_pos_arc_plane


 # Default cycle spindle axis to Z
  set mom_cycle_spindle_axis 2


  if { ![string match "*3_axis_mill*" $mom_kin_machine_type] } {

    if { $mom_kin_4th_axis_type == "Head" } {

      if [EQ_is_equal [expr abs($mom_tool_axis(0))] 1.0] {
        set mom_cycle_spindle_axis 0
      }

      if [EQ_is_equal [expr abs($mom_tool_axis(1))] 1.0] {
        set mom_cycle_spindle_axis 1
      }

      if { $mom_kin_5th_axis_type == "Table" } {

        if { [EQ_is_equal [expr abs($mom_pos(3))] 90.0] || [EQ_is_equal [expr abs($mom_pos(3))] 270.0] } {

          switch $mom_kin_4th_axis_plane {
            "YZ" {
              set mom_cycle_spindle_axis 1
            }
            "ZX" {
              set mom_cycle_spindle_axis 0
            }
          }
        }
      }
    }
  }


  switch $mom_cycle_spindle_axis {
    0 {
      set mom_cutcom_plane  YZ
      set mom_pos_arc_plane YZ
      set principal_axis X
    }
    1 {
      set mom_cutcom_plane  ZX
      set mom_pos_arc_plane ZX
      set principal_axis Y
    }
    2 {
      set mom_cutcom_plane  XY
      set mom_pos_arc_plane XY
      set principal_axis Z
    }
    default {
      set mom_cutcom_plane  UNDEFINED
      set mom_pos_arc_plane UNDEFINED
      set principal_axis ""
    }
  }


  if { $suppress_principal_axis && [string length $principal_axis] > 0 } {
    MOM_suppress once $principal_axis
  }


  if { $force_plane_code } {
    global cycle_init_flag

    if { [info exists cycle_init_flag] && [string match "TRUE" $cycle_init_flag] } {
      MOM_force once G_plane
    }
  }
}


#=============================================================
proc PB_CMD_set_principal_axis { } {
#=============================================================
# This command can be used to determine the principal axis.
#
# => It can be used to determine a proper work plane when the
#    "Work Plane" parameter is not specified with an operation.
#
#
# <06-22-09 gsl> - Extracted from PB_CMD_set_cycle_plane
# <10-09-09 gsl> - Do not define mom_pos_arc_plane unless it doesn't exist.
# <03-10-10 gsl> - Respect tool axis for 3-axis & XZC cases
# <01-21-11 gsl> - Enhance header description
# <07-12-12 gsl> - Find principal axis for XZC-mill from the spindle axis
#

   global mom_cycle_spindle_axis
   global mom_spindle_axis
   global mom_cutcom_plane mom_pos_arc_plane


  # Initialization spindle axis
   global mom_kin_spindle_axis
   global mom_sys_spindle_axis
   if { ![info exists mom_kin_spindle_axis] } {
      set mom_kin_spindle_axis(0) 0.0
      set mom_kin_spindle_axis(1) 0.0
      set mom_kin_spindle_axis(2) 1.0
   }
   if { ![info exists mom_sys_spindle_axis] } {
      VMOV 3 mom_kin_spindle_axis mom_sys_spindle_axis
   }
   if { ![info exists mom_spindle_axis] } {
      VMOV 3 mom_sys_spindle_axis mom_spindle_axis
   }


  # Default cycle spindle axis to Z
   set mom_cycle_spindle_axis 2


  # Respect tool axis only for 3-axis mill
   global mom_kin_machine_type mom_tool_axis
   if [string match "3_axis_mill" $mom_kin_machine_type] {
      VMOV 3 mom_tool_axis spindle_axis
   } else {
      VMOV 3 mom_spindle_axis spindle_axis
   }


   if { [EQ_is_equal [expr abs($spindle_axis(0))] 1.0] } {
      set mom_cycle_spindle_axis 0
   }

   if { [EQ_is_equal [expr abs($spindle_axis(1))] 1.0] } {
      set mom_cycle_spindle_axis 1
   }


   switch $mom_cycle_spindle_axis {
      0 {
         set mom_cutcom_plane  YZ
      }
      1 {
         set mom_cutcom_plane  ZX
      }
      2 {
         set mom_cutcom_plane  XY
      }
      default {
         set mom_cutcom_plane  UNDEFINED
      }
   }

  # Set arc plane when it's not defined
   if { ![info exists mom_pos_arc_plane] || $mom_pos_arc_plane == "" } {
      set mom_pos_arc_plane $mom_cutcom_plane
   }
}


#=============================================================
proc PB_CMD_smart_file_switch { } {
#=============================================================
    global mom_operation_name mom_tool_name
    global my_out_dir my_valid_files
    global ptp_file_name mom_output_file_full_name
    global mom_parent_group_name mom_group_name
    global mom_output_file_basename
    global my_group_level_map my_group_stack
    global my_is_merged_op
    global my_current_merged_group my_current_merged_tool my_skip_current_merged_group

    set my_is_merged_op 0

    if { ![info exists mom_operation_name] || $mom_operation_name == "" } { return }

    # 使用 my_group_stack 确定层级
    set op_parent ""
    set op_grandparent ""

    if { [info exists my_group_stack] } {
        set stack_len [llength $my_group_stack]
        if { $stack_len > 0 } {
            set op_parent [lindex $my_group_stack end]
        }
        if { $stack_len > 1 } {
            set op_grandparent [lindex $my_group_stack end-1]
        }
    }

    # 容错处理：如果栈为空，尝试使用原生变量
    if { $op_parent == "" } {
        catch { set op_parent $mom_group_name }
        if { $op_parent == "" } { catch { set op_parent [MOM_ask_group_name] } }
        catch { set op_grandparent $mom_parent_group_name }

        if { $op_parent == $mom_operation_name } {
            if { $op_grandparent != "" && $op_grandparent != $mom_operation_name && $op_grandparent != "NC_PROGRAM" && $op_grandparent != "PROGRAM" } {
                set op_parent $op_grandparent
                set op_grandparent ""
            } elseif { [info exists my_group_level_map($mom_operation_name)] } {
                set op_parent $my_group_level_map($mom_operation_name)
            }
        }
        if { $op_grandparent == "" && $op_parent != "" } {
            if { [info exists my_group_level_map($op_parent)] } {
                set op_grandparent $my_group_level_map($op_parent)
            }
        }
    }

    # 容错处理：如果直接选中某个组进行后处理，NX 可能会将 mom_parent_group_name 设置为与 mom_group_name 相同。
    # 识别二级组的约定：组名末尾为“-”加数字
    if { [regexp {^(.*)-[0-9]+$} $op_parent match prefix] } {
        # 这是一个二级组
        if { $op_grandparent == "" || $op_grandparent == $op_parent } {
            # 如果直接选中二级组，推断其一级组（父组）为前缀
            set op_grandparent $prefix
        }
    } else {
        # 不是二级组，那就是一级组（或根组）
        if { $op_grandparent == "" || $op_grandparent == $op_parent } {
            set op_grandparent "NC_PROGRAM"
        }
    }

    # 3. 核心逻辑：基于 NX 原生的父组属性判断绝对层级
    # 确定父级目录 (parent_dir) 和 输出文件名 (file_target)
    set parent_dir ""
    set my_is_merged_op 0

    set safe_tool_name ""
    if { [info exists mom_tool_name] } {
        set safe_tool_name [string map [list " " "_" "/" "_" "\\" "_" "*" "_" ":" "_" "?" "_" "<" "_" ">" "_" "|" "_" "\"" "_"] $mom_tool_name]
    }

    if { $op_parent == "" || $op_parent == "NC_PROGRAM" || $op_parent == "PROGRAM" } {
        # Level 0: 直接在根目录下的工序 -> 不建文件夹，文件名为工序名
        set parent_dir ""
        set file_target "${mom_operation_name}_${safe_tool_name}"
    } else {
        if { $op_grandparent == "" || $op_grandparent == "NC_PROGRAM" || $op_grandparent == "PROGRAM" } {
            # Level 1: op_parent 是一级目录 (例如 TOP) -> 文件夹为 TOP，文件名为工序名
            set parent_dir $op_parent
            set file_target "${mom_operation_name}_${safe_tool_name}"
        } else {
            # Level 2 (或更深): op_parent 是二级目录，op_grandparent 是一级目录
            # -> 文件夹为一级目录 (op_grandparent)，文件名为二级目录名 (op_parent)，单一 NC 文件
            set parent_dir $op_grandparent
            set file_target "${op_parent}"
            set my_is_merged_op 1
        }
    }

# ==========================================================
# 3.5 无刀库机床安全检查：二级程序组内刀具一致性校验（增强版）
# ==========================================================
# 说明：针对无刀库机床（刀具号默认为0）的特殊情况，
# 采用“刀具名称+类型+直径+下半径+总长”构建指纹进行比对，
# 避免仅凭刀号判断导致的误报或失效。
# ==========================================================

  if { $my_is_merged_op == 1 } {
      # 1. 获取当前刀具的各项关键参数
      set current_tool_name    "UNDEFINED"
      set current_tool_type    "UNDEFINED"
      set current_tool_dia     0.0
      set current_tool_corner  0.0
      set current_tool_length  0.0

      # 捕获变量（防止变量不存在导致程序中断）
      if { [info exists mom_tool_name] }      { set current_tool_name    $mom_tool_name }
      if { [info exists mom_tool_type] }      { set current_tool_type    $mom_tool_type }
      if { [info exists mom_tool_diameter] }  { set current_tool_dia     $mom_tool_diameter }
      if { [info exists mom_tool_corner1_radius] } { set current_tool_corner  $mom_tool_corner1_radius }
      if { [info exists mom_tool_length] }    { set current_tool_length  $mom_tool_length }

      # 2. 构建当前刀具的“唯一指纹”字符串
      # 格式示例：EM_12_R1_MILL|12.000|1.000|50.000
      set current_tool_fingerprint "${current_tool_name}|${current_tool_type}|${current_tool_dia}|${current_tool_corner}|${current_tool_length}"

      # 3. 定义全局变量用于记录组内第一把刀的指纹（请确保在程序头或组开始事件中初始化）
      global SUB_GROUP_BASE_TOOL_FINGERPRINT

      # 4. 开始比对逻辑
      if { ![info exists SUB_GROUP_BASE_TOOL_FINGERPRINT] } {
          # A. 如果指纹不存在，说明是该组第一个工序，记录基准指纹
          set SUB_GROUP_BASE_TOOL_FINGERPRINT $current_tool_fingerprint
      } else {
          # B. 如果指纹已存在，比对当前刀具与基准刀具
          if { $current_tool_fingerprint != $SUB_GROUP_BASE_TOOL_FINGERPRINT } {
              # === 触发报警：刀具参数不一致！ ===
              MOM_output_literal "(ERROR: TOOL INCONSISTENCY DETECTED IN SUB-PROGRAM GROUP!)"
              MOM_output_literal "(Base Tool : $SUB_GROUP_BASE_TOOL_FINGERPRINT)"
              MOM_output_literal "(Current Tool: $current_tool_fingerprint)"
              MOM_output_literal "(ACTION: MANUAL CHECK REQUIRED - Ensure correct tool is loaded!)"

              # === 自动拦截开关 ===
              # 如果您希望发现不一致时自动停止后处理，取消下面一行的注释
              # MOM_abort "ERROR: Tool mismatch without tool changer detected!"
          }
      }
  }

# 注意：在二级程序组结束事件（Program End 或 Group End）中，
# 建议执行 unset SUB_GROUP_BASE_TOOL_FINGERPRINT 以重置状态，避免跨组干扰。
# ==========================================================

    # 4. 构建目标路径
    set file_target [string map [list "<" "_" ">" "_" ":" "_" "\"" "_" "/" "_" "\\" "_" "|" "_" "?" "_" "*" "_"] $file_target]

    if { $parent_dir == "" } {
        set target_folder_path $my_out_dir
    } else {
        set folder_name [string map [list "<" "_" ">" "_" ":" "_" "\"" "_" "/" "_" "\\" "_" "|" "_" "?" "_" "*" "_"] $parent_dir]
        set target_folder_path [file nativename [file join $my_out_dir $folder_name]]
        # 确保目录存在
        if { ![file exists $target_folder_path] } {
            catch { file mkdir $target_folder_path }
        }
    }

    set target_file_path [file nativename [file join $target_folder_path "${file_target}.nc"]]

    # 4.5 跳过逻辑已禁用，重定向逻辑不再需要
    set file_to_delete_after_close ""

    set current_ptp ""
    if { [info exists ptp_file_name] } { set current_ptp [file nativename $ptp_file_name] }

    # --- 5. 执行文件切换 ---
    # 强制路径标准化比较
    set norm_current [file normalize $current_ptp]
    set norm_target [file normalize $target_file_path]

    # 记录到 listing file 方便调试
    # catch { MOM_output_to_listing_device "DEBUG: OP=$mom_operation_name, CURRENT=$norm_current, TARGET=$norm_target" }

    if { $norm_current != $norm_target } {
        # 处理当前正被占用的旧文件
        if { $current_ptp != "" } {
            if { [lsearch -exact $my_valid_files $norm_current] != -1 || [lsearch -exact $my_valid_files $current_ptp] != -1 } {
                # 是我们自己的有效文件，写入程序尾并安全关闭
                # catch { MOM_output_to_listing_device "DEBUG: Closing valid file: $current_ptp" }
                if { [llength [info commands MOM_output_literal]] } {
                    catch { MOM_output_literal "G05.1 Q0" }
                    # catch { MOM_output_literal "G91 G28 Z0.0" }
                    # catch { MOM_output_literal "G90" } ;# <--- 重要：G28 后必须切回 G90，否则后续坐标会错乱！
                    catch { MOM_output_literal "M05" }
                    catch { MOM_output_literal "M09" }
                    catch { MOM_output_literal "G40 G49 G80" }
                    catch { MOM_output_literal "M30" }
                }
                catch { MOM_set_seq_off }
                if { [llength [info commands MOM_do_template]] } {
                    catch { MOM_do_template rewind_stop_code }
                }
                catch { MOM_close_output_file $current_ptp }

                # 切换文件时，重置刀具指纹基准，防止跨文件误报
                global SUB_GROUP_BASE_TOOL_FINGERPRINT
                catch { unset SUB_GROUP_BASE_TOOL_FINGERPRINT }
            } else {
                # 不在白名单里，是 NX 刚生成的流氓文件！
                # catch { MOM_output_to_listing_device "DEBUG: Deleting rogue file: $current_ptp" }
                catch { MOM_close_output_file $current_ptp }
                catch { file delete -force $current_ptp }
                set current_nc [string map {".ptp" ".nc"} $current_ptp]
                catch { file delete -force $current_nc }
            }
        }

        # 如果是本次后处理第一次打开这个文件，先删除旧文件
        if { [lsearch -exact $my_valid_files $norm_target] == -1 } {
            # catch { MOM_output_to_listing_device "DEBUG: First time opening: $target_file_path" }
            catch { file delete -force $target_file_path }
            set temp_ptp [string map {".nc" ".ptp"} $target_file_path]
            catch { file delete -force $temp_ptp }
        } else {
            # catch { MOM_output_to_listing_device "DEBUG: Re-opening existing valid file: $target_file_path" }
        }

        # 打开我们要的新文件
        if { ![catch {MOM_open_output_file $target_file_path} err] } {
            set ptp_file_name $target_file_path
            set mom_output_file_full_name $target_file_path

            # 加入白名单 (保存标准化路径)
            if { [lsearch -exact $my_valid_files $norm_target] == -1 } {
                lappend my_valid_files $norm_target
            }

            # 输出调试信息
            if { [info exists debug_info] } { catch { MOM_output_literal "$debug_info" } }

            # ==========================================
            # 独立文件安全初始化包 (Safe Start Package)
            # ==========================================

            global mom_seqnum mom_sys_seqnum_start
            if { [info exists mom_sys_seqnum_start] } {
                catch { set mom_seqnum $mom_sys_seqnum_start }
            } else {
                catch { set mom_seqnum 10 }
            }

            global mom_date mom_tool_diameter mom_tool_corner1_radius mom_tool_lower_corner_radius
            global mom_tool_nose_radius mom_tool_profile_radius
            global mom_tool_adjust_register mom_cutcom_adjust_register mom_stock_part mom_stock_floor
            global mom_tool_minimum_length mom_tool_holder_libref

            set cur_date [clock format [clock seconds] -format "%Y-%m-%d %H:%M"]
            set t_dia [expr {[info exists mom_tool_diameter] ? $mom_tool_diameter : 0.0}]
            if { [info exists mom_tool_lower_corner_radius] } {
                set t_cr $mom_tool_lower_corner_radius
            } elseif { [info exists mom_tool_nose_radius] } {
                set t_cr $mom_tool_nose_radius
            } elseif { [info exists mom_tool_profile_radius] } {
                set t_cr $mom_tool_profile_radius
            } else {
                set t_cr [expr {[info exists mom_tool_corner1_radius] ? $mom_tool_corner1_radius : 0.0}]
            }
            set t_h [expr {[info exists mom_tool_length_adjust_register] ? $mom_tool_length_adjust_register : 0}]
            set t_d [expr {[info exists mom_cutcom_adjust_register] ? $mom_cutcom_adjust_register : 0}]
            set t_stock_p [expr {[info exists mom_stock_part] ? $mom_stock_part : 0.0}]
            set t_stock_f [expr {[info exists mom_stock_floor] ? $mom_stock_floor : 0.0}]
            set t_min_len [expr {[info exists mom_tool_minimum_length] ? $mom_tool_minimum_length : 0.0}]
            set t_holder_lib "NONE"
            if { [info exists mom_tool_holder_libref] } { set t_holder_lib $mom_tool_holder_libref }

            global mom_my_prog_name mom_my_date_str mom_my_tool_name mom_my_dia mom_my_cr mom_my_min_len mom_my_holder mom_my_h_reg mom_my_d_reg mom_my_stock_p mom_my_stock_f mom_my_z_min
            set mom_my_prog_name ${file_target}
            set mom_my_date_str ${cur_date}
            set mom_my_tool_name ${mom_tool_name}
            set mom_my_dia [format "%.1f" $t_dia]
            set mom_my_cr [format "%.1f" $t_cr]
            set mom_my_min_len [format "%.2f" $t_min_len]
            set mom_my_holder ${t_holder_lib}
            set mom_my_h_reg [format "%02d" $t_h]
            set mom_my_d_reg [format "%02d" $t_d]
            set mom_my_stock_p [format "%.3f" $t_stock_p]
            set mom_my_stock_f [format "%.3f" $t_stock_f]
            global mom_z_min
            set z_min [expr {[info exists mom_z_min] ? $mom_z_min : 0.0}]
            set mom_my_z_min [format "%.3f" $z_min]
            catch { MOM_do_template rewind_stop_code }
            catch { MOM_output_literal "(PROGRAM: $mom_my_prog_name)" }
            catch { MOM_output_literal "(DATE: $mom_my_date_str)" }
            catch { MOM_output_literal "(TOOL: $mom_my_tool_name)" }
            catch { MOM_output_literal "(DIA: $mom_my_dia | CR: $mom_my_cr)" }
            catch { MOM_output_literal "(MIN LENGTH: $mom_my_min_len | HOLDER: $mom_my_holder)" }
            catch { MOM_output_literal "(COMP: H$mom_my_h_reg | D$mom_my_d_reg)" }
            catch { MOM_output_literal "(STOCK: XY $mom_my_stock_p MM | Z $mom_my_stock_f MM)" }
            catch { MOM_output_literal "(Z-MIN: $mom_my_z_min MM)" }
            # catch { MOM_output_literal "G91 G28 Z0.0" } ;# 注释掉，防止与 tool_change 重复输出
            catch { MOM_do_template start_of_program }

            catch { MOM_force once G_mode G_cutcom G_adjust G_fixture_offset }
            catch { MOM_force once M_spindle S M_coolant }
            catch { MOM_force once feed }

            catch { MOM_force once T M }
            catch { MOM_force once G_adjust H_adjust }
            catch { MOM_do_template tool_change }

            if { [llength [info commands MOM_do_template]] } {
                catch { MOM_do_template tool_change_1 }
                catch { MOM_do_template tool_length_adjust }
            }

            # 进阶建议四：高速高精度模式（HSM）智能触发 (已注释，所有类型都输出)
            # global mom_operation_type
            # if { [info exists mom_operation_type] } {
            #     if { [string match "*Point*" $mom_operation_type] || [string match "*Drill*" $mom_operation_type] } {
            #         # 钻孔类工序，禁止输出高速高精度，防止固定循环报警
            #     } else {
            #         catch { MOM_do_template start_of_program_highspeed }
            #     }
            # } else {
            #     catch { MOM_do_template start_of_program_highspeed }
            # }
            catch { MOM_do_template start_of_program_highspeed }

            catch { MOM_force once G_mode G_motion G_cutcom G_plane G_adjust S M_spindle M_coolant F T M }
            catch { MOM_do_template initial_move }
        }
    }
}


#=============================================================
proc PB_CMD_start_of_alignment_character { } {
#=============================================================
# This command can be used to output a special sequence number character.
# Replace the ":" with any character that you require.
# You must use the command "PB_CMD_end_of_alignment_character" to reset
# the sequence number back to the original setting.
#
  global mom_sys_leader saved_seq_num
  set saved_seq_num $mom_sys_leader(N)
  set mom_sys_leader(N) ":"
}


#=============================================================
proc PB_CMD_start_of_operation_force_addresses { } {
#=============================================================
  MOM_force once S M_spindle X Y Z fourth_axis fifth_axis F
}


#=============================================================
proc PB_CMD_suppress_linear_block_plane_code { } {
#=============================================================
# This command is to be called in the linear move event to suppress
# G_plane address when the cutcom status has not changed.
# -- Assuming G_cutcom address is modal and G_plane exists in the block
#
#<10-11-09 gsl> - New
#<01-20-11 gsl> - Force out plane code for the 1st linear move when CUTCOM is on
#<03-16-12 gsl> - Added use of CALLED_BY
#

  # Restrict this command to be executed only by MOM_linear_move
   if { ![CALLED_BY "MOM_linear_move"] } {
return
   }


   global mom_cutcom_status mom_user_prev_cutcom_status

   if { ![info exists mom_cutcom_status] } {
      set mom_cutcom_status UNDEFINED
   }

   if { ![info exists mom_user_prev_cutcom_status] } {
      set mom_user_prev_cutcom_status UNDEFINED
   }


  # Suppress plane code when no change of CUTCOM status
   if { [string match "UNDEFINED" $mom_cutcom_status] ||\
        [string match $mom_user_prev_cutcom_status $mom_cutcom_status] } {

      MOM_suppress once G_plane

   } else {

     # Force out plane code for the 1st CUTCOM activation of an operation,
     # otherwise plane code will only come out when work plane has changed
     # since last activation.
     #

      set force_1st_plane_code  "1"


      if { $force_1st_plane_code } {

        # This var should have been set in PB_first_linear_move
         global mom_sys_first_linear_move

         if { ![info exists mom_sys_first_linear_move] || $mom_sys_first_linear_move } {

            if { [string match "LEFT"  $mom_cutcom_status] ||\
                 [string match "RIGHT" $mom_cutcom_status] ||\
                 [string match "ON"    $mom_cutcom_status] } {

               MOM_force once G_plane
               set mom_sys_first_linear_move 0
            }
         }
      }
   }


   if { ![string match $mom_user_prev_cutcom_status $mom_cutcom_status] } {
      set mom_user_prev_cutcom_status $mom_cutcom_status
   }
}


#=============================================================
proc PB_CMD_tool_change_force_addresses { } {
#=============================================================
  MOM_force once G_adjust H X Y Z S fourth_axis fifth_axis
}


#=============================================================
proc ABORT_EVENT_CHECK { } {
#=============================================================
# Called by every motion event to abort its handler based on
# the setting of mom_sys_abort_next_event.
#
   if { [info exists ::mom_sys_abort_next_event] && $::mom_sys_abort_next_event } {
      if { [CMD_EXIST PB_CMD_kin_abort_event] } {
         PB_CMD_kin_abort_event
      }
   }
}


#=============================================================
proc ARCTAN { y x } {
#=============================================================
   global PI

   if { [EQ_is_zero $y] } { set y 0 }
   if { [EQ_is_zero $x] } { set x 0 }

   if { [expr $y == 0] && [expr $x == 0] } {
      return 0
   }

   set ang [expr atan2($y,$x)]

   if { $ang < 0 } {
      return [expr $ang + $PI*2]
   } else {
      return $ang
   }
}


#=============================================================
proc ARR_sort_array_to_list { ARR {by_value 0} {by_decr 0} } {
#=============================================================
# This command will sort and build a list of elements of an array.
#
#   ARR      : Array Name
#   by_value : 0 Sort elements by names (default)
#              1 Sort elements by values
#   by_decr  : 0 Sort into increasing order (default)
#              1 Sort into decreasing order
#
#   Return a list of {name value} couplets
#
#-------------------------------------------------------------
# Feb-24-2016 gsl - Added by_decr flag
#
   upvar $ARR arr

   set list [list]
   foreach { e v } [array get arr] {
      lappend list "$e $v"
   }

   set val [lindex [lindex $list 0] $by_value]

   if { $by_decr } {
      set trend "decreasing"
   } else {
      set trend "increasing"
   }

   if [expr $::tcl_version > 8.1] {
      if [string is integer "$val"] {
         set list [lsort -integer    -$trend -index $by_value $list]
      } elseif [string is double "$val"] {
         set list [lsort -real       -$trend -index $by_value $list]
      } else {
         set list [lsort -dictionary -$trend -index $by_value $list]
      }
   } else {
      set list    [lsort -dictionary -$trend -index $by_value $list]
   }

return $list
}


#=============================================================
proc CALLED_BY { caller {out_warn 0} args } {
#=============================================================
# This command can be used in the beginning of a command
# to designate a specific caller for the command in question.
#
# - Users can set the optional flag "out_warn" to "1" to output
#   warning message when a command is being called by a
#   non-designated caller. By default, warning message is suppressed.
#
#  Syntax:
#    if { ![CALLED_BY "cmd_string"] } { return ;# or do something }
#  or
#    if { ![CALLED_BY "cmd_string" 1] } { return ;# To output warning }
#
# Revisions:
#-----------
# 05-25-2010 gsl - Initial implementation
# 03-09-2011 gsl - Enhanced description
# 06-29-2018 gsl - Only compare the 0th element in command string
#

   if { [info level] <= 2 } {
return 0
   }

   if { ![string compare "$caller" [lindex [info level -2] 0] ] } {
return 1
   } else {
      if { $out_warn } {
         CATCH_WARNING "\"[lindex [info level -1] 0]\" cannot be executed in \"[lindex [info level -2] 0]\". \
                        It must be called by \"$caller\"!"
      }
return 0
   }
}


#=============================================================
proc CATCH_WARNING { msg {output 1} } {
#=============================================================
# This command is called in a post to spice up the message to be output to the warning file.
#
   global mom_warning_info
   global mom_motion_event
   global mom_event_number
   global mom_motion_type
   global mom_operation_name


   if { $output == 1 } {

      set level [info level]
      set call_stack ""
      for { set i 1 } { $i < $level } { incr i } {
         set call_stack "$call_stack\[ [lindex [info level $i] 0] \]"
      }

      global mom_o_buffer
      if { ![info exists mom_o_buffer] } {
         set mom_o_buffer ""
      }

      if { ![info exists mom_motion_event] } {
         set mom_motion_event ""
      }

      if { [info exists mom_operation_name] && [string length $mom_operation_name] } {
         set mom_warning_info "$msg\n\  Operation $mom_operation_name - Event $mom_event_number [MOM_ask_event_type] :\
                               $mom_motion_event ($mom_motion_type)\n\    $mom_o_buffer\n\      $call_stack\n"
      } else {
         set mom_warning_info "$msg\n\  Event $mom_event_number [MOM_ask_event_type] :\
                               $mom_motion_event ($mom_motion_type)\n\    $mom_o_buffer\n\      $call_stack\n"
      }

      MOM_catch_warning
   }

   # Restore mom_warning_info for subsequent use
   set mom_warning_info $msg
}


#=============================================================
proc CMD_EXIST { cmd {out_warn 0} args } {
#=============================================================
# This command can be used to detect the existence of a command
# before executing it.
# - Users can set the optional flag "out_warn" to "1" to output
#   warning message when a command to be called doesn't exist.
#   By default, warning message is suppressed.
#
#  Syntax:
#    if { [CMD_EXIST "cmd_string"] } { cmd_string }
#  or
#    if { [CMD_EXIST "cmd_string" 1] } { cmd_string ;# To output warning }
#
# Revisions:
#-----------
# 05-25-10 gsl - Initial implementation
# 03-09-11 gsl - Enhanced description
#

   if { [llength [info commands "$cmd"] ] } {
return 1
   } else {
      if { $out_warn } {
         CATCH_WARNING "Command \"$cmd\" called by \"[lindex [info level -1] 0]\" does not exist!"
      }
return 0
   }
}


#=============================================================================
proc COMPARE_NX_VERSION { this_ver target_ver } {
#=============================================================================
# Compare a given NX version with target version.
# ==> Number of fields will be compared based on the number of "." contained in target.
#
# Return 1: Newer
#        0: Same
#       -1: Older
#

   set vlist_1 [split $this_ver   "."]
   set vlist_2 [split $target_ver "."]

   set ver_check 0

   set idx 0
   foreach v2 $vlist_2 {

      if { $ver_check == 0 } {
         set v1 [lindex $vlist_1 $idx]
         if { $v1 > $v2 } {
            set ver_check 1
         } elseif { $v1 == $v2 } {
            set ver_check 0
         } else {
            set ver_check -1
         }
      }

      if { $ver_check != 0 } {
         break
      }

      incr idx
   }

return $ver_check
}


#=============================================================
proc DELAY_TIME_SET { } {
#=============================================================
  global mom_sys_delay_param mom_delay_value
  global mom_delay_revs mom_delay_mode delay_time

   # post builder provided format for the current mode:
    if {[info exists mom_sys_delay_param(${mom_delay_mode},format)] != 0} {
      MOM_set_address_format dwell $mom_sys_delay_param(${mom_delay_mode},format)
    }

    switch $mom_delay_mode {
      SECONDS {set delay_time $mom_delay_value}
      default {set delay_time $mom_delay_revs}
    }
}


#=============================================================================
proc DO_BLOCK { block args } {
#=============================================================================
# May-10-2017 gsl - New (PB v12.0)
#
   set option [lindex $args 0]

   if { [CMD_EXIST MOM_has_definition_element] } {
      if { [MOM_has_definition_element BLOCK $block] } {
         if { $option == "" } {
            return [MOM_do_template $block]
         } else {
            return [MOM_do_template $block $option]
         }
      } else {
         CATCH_WARNING "Block template $block not found."
      }
   } else {
      if { $option == "" } {
         return [MOM_do_template $block]
      } else {
         return [MOM_do_template $block $option]
      }
   }
}


#=============================================================
proc EXEC { command_string {__wait 1} } {
#=============================================================
# This command can be used in place of the intrinsic Tcl "exec" command
# of which some problems have been reported under Win64 O/S and multi-core
# processors environment.
#
#
# Input:
#   command_string -- command string
#   __wait         -- optional flag
#                     1 (default)   = Caller will wait until execution is complete.
#                     0 (specified) = Caller will not wait.
#
# Return:
#   Results of execution
#
#
# Revisions:
#-----------
# 05-19-10 gsl - Initial implementation
#

   global tcl_platform


   if { $__wait } {

      if { [string match "windows" $tcl_platform(platform)] } {

         global env mom_logname

        # Create a temporary file to collect output
         set result_file "$env(TEMP)/${mom_logname}__EXEC_[clock clicks].out"

        # Clean up existing file
         set result_file [string map [list "\\" "/"] $result_file]
        #set result_file [string map [list " " "\\ "] $result_file]

         if { [file exists "$result_file"] } {
            file delete -force "$result_file"
         }

        #<11-05-2013> Escape spaces
         set cmd [concat exec $command_string > \"$result_file\"]
         set cmd [string map [list "\\" "\\\\"] $cmd]
         set result_file [string map [list " " "\\ "] $result_file]

         eval $cmd

        # Return results & clean up temporary file
         if { [file exists "$result_file"] } {
            set fid [open "$result_file" r]
            set result [read $fid]
            close $fid

            file delete -force "$result_file"

           return $result
         }

      } else {

         set cmd [concat exec $command_string]

        return [eval $cmd]
      }

   } else {

      if { [string match "windows" $tcl_platform(platform)] } {

         set cmd [concat exec $command_string &]
         set cmd [string map [list "\\" "\\\\"] $cmd]

        return [eval $cmd]

      } else {

        return [exec $command_string &]
      }
   }
}




#=============================================================
proc HANDLE_FIRST_LINEAR_MOVE { } {
#=============================================================
# Called by MOM_linear_move to handle the 1st linear move of an operation.
#
   if { ![info exists ::first_linear_move] } {
      set ::first_linear_move 0
   }
   if { !$::first_linear_move } {
      PB_first_linear_move
      incr ::first_linear_move
   }
}


#=============================================================
proc INFO { args } {
#=============================================================
   MOM_output_to_listing_device [join $args]
}


#=============================================================
proc LIMIT_ANGLE { a } {
#=============================================================

   set a [expr fmod($a,360)]
   set a [expr ($a < 0) ? ($a + 360) : $a]

return $a
}


#=============================================================
proc MAXMIN_ANGLE { a max min {tol_flag 0} } {
#=============================================================

   if { $tol_flag == 0 } { ;# Direct comparison

      while { $a < $min } { set a [expr $a + 360.0] }
      while { $a > $max } { set a [expr $a - 360.0] }

   } else { ;# Tolerant comparison

      while { [EQ_is_lt $a $min] } { set a [expr $a + 360.0] }
      while { [EQ_is_gt $a $max] } { set a [expr $a - 360.0] }
   }

return $a
}


#=============================================================
proc OPERATOR_MSG { msg {seq_no 0} } {
#=============================================================
# This command will output a single or a set of operator message(s).
#
#   msg    : Message(s separated by new-line character)
#   seq_no : 0 Output message without sequence number (Default)
#            1 Output message with sequence number
#

   foreach s [split $msg \n] {
      set s1 "$::mom_sys_control_out $s $::mom_sys_control_in"
      if { !$seq_no } {
         MOM_suppress once N
      }
      MOM_output_literal $s1
   }

   set ::mom_o_buffer ""
}


#=============================================================
proc PAUSE { args } {
#=============================================================
# Revisions:
#-----------
# 05-19-10 gsl - Use EXEC command
#

   global env

   if { [info exists env(PB_SUPPRESS_UGPOST_DEBUG)]  &&  $env(PB_SUPPRESS_UGPOST_DEBUG) == 1 } {
  return
   }


   global gPB

   if { [info exists gPB(PB_disable_MOM_pause)]  &&  $gPB(PB_disable_MOM_pause) == 1 } {
  return
   }


   global tcl_platform

   set cam_aux_dir  [MOM_ask_env_var UGII_CAM_AUXILIARY_DIR]

   if { [string match "*windows*" $tcl_platform(platform)] } {
      set ug_wish "ugwish.exe"
   } else {
      set ug_wish ugwish
   }

   if { [file exists ${cam_aux_dir}$ug_wish]  &&  [file exists ${cam_aux_dir}mom_pause.tcl] } {

      set title ""
      set msg ""

      if { [llength $args] == 1 } {
         set msg [lindex $args 0]
      }

      if { [llength $args] > 1 } {
         set title [lindex $args 0]
         set msg [lindex $args 1]
      }

      set command_string [concat \"${cam_aux_dir}$ug_wish\" \"${cam_aux_dir}mom_pause.tcl\" \"$title\" \"$msg\"]

      set res [EXEC $command_string]


      switch [string trim $res] {
         no {
            set gPB(PB_disable_MOM_pause) 1
         }
         cancel {
            set gPB(PB_disable_MOM_pause) 1

            uplevel #0 {
               if { [CMD_EXIST MOM_abort_program] } {
                  MOM_abort_program "*** User Abort Post Processing *** "
               } else {
                  MOM_abort "*** User Abort Post Processing *** "
               }
            }
         }
         default {
            return
         }
      }

   } else {

      CATCH_WARNING "PAUSE not executed -- \"$ug_wish\" or \"mom_pause.tcl\" not found"
   }
}


#=============================================================
proc PAUSE_win64 { args } {
#=============================================================
   global env
   if { [info exists env(PB_SUPPRESS_UGPOST_DEBUG)]  &&  $env(PB_SUPPRESS_UGPOST_DEBUG) == 1 } {
  return
   }

   global gPB
   if { [info exists gPB(PB_disable_MOM_pause)]  &&  $gPB(PB_disable_MOM_pause) == 1 } {
  return
   }


   set cam_aux_dir  [MOM_ask_env_var UGII_CAM_AUXILIARY_DIR]
   set ug_wish "ugwish.exe"

   if { [file exists ${cam_aux_dir}$ug_wish] &&\
        [file exists ${cam_aux_dir}mom_pause_win64.tcl] } {

      set title ""
      set msg ""

      if { [llength $args] == 1 } {
         set msg [lindex $args 0]
      }

      if { [llength $args] > 1 } {
         set title [lindex $args 0]
         set msg [lindex $args 1]
      }


     ######
     # Define a scratch file and pass it to mom_pause_win64.tcl script -
     #
     #   A separated process will be created to construct the Tk dialog.
     #   This process will communicate with the main process via the state of a scratch file.
     #   This scratch file will collect the messages that need to be conveyed from the
     #   child process to the main process.
     ######
      global mom_logname
      set pause_file_name "$env(TEMP)/${mom_logname}_mom_pause_[clock clicks].txt"


     ######
     # Path names should be per unix style for "open" command
     ######
      set pause_file_name [string map [list "\\" "/"] $pause_file_name]
      set pause_file_name [string map [list " " "\\ "] $pause_file_name]
      set cam_aux_dir [string map [list "\\" "/"] $cam_aux_dir]
      set cam_aux_dir [string map [list " " "\\ "] $cam_aux_dir]

      if [file exists $pause_file_name] {
         file delete -force $pause_file_name
      }


     ######
     # Note that the argument order for mom_pasue.tcl has been changed
     # The assumption at this point is we will always have the communication file as the first
     # argument and optionally the title and message as the second and third arguments
     ######
      open "|${cam_aux_dir}$ug_wish ${cam_aux_dir}mom_pause_win64.tcl ${pause_file_name} {$title} {$msg}"


     ######
     # Waiting for the mom_pause to complete its process...
     # - This is indicated when the scratch file materialized and became read-only.
     ######
      while { ![file exists $pause_file_name] || [file writable $pause_file_name] } { }


     ######
     # Delay a 100 milli-seconds to ensure that sufficient time is given for the other process to complete.
     ######
      after 100


     ######
     # Open the scratch file to read and process the information.  Close it afterward.
     ######
      set fid [open "$pause_file_name" r]

      set res [string trim [gets $fid]]
      switch $res {
         no {
            set gPB(PB_disable_MOM_pause) 1
         }
         cancel {
            close $fid
            file delete -force $pause_file_name

            set gPB(PB_disable_MOM_pause) 1

            uplevel #0 {
               if { [CMD_EXIST MOM_abort_program] } {
                  MOM_abort_program "*** User Abort Post Processing *** "
               } else {
                  MOM_abort "*** User Abort Post Processing *** "
               }
            }
         }
         default {}
      }


     ######
     # Delete the scratch file
     ######
      close $fid
      file delete -force $pause_file_name
   }
}


#=============================================================
proc PAUSE_x { args } {
#=============================================================
   global env
   if { [info exists env(PB_SUPPRESS_UGPOST_DEBUG)]  &&  $env(PB_SUPPRESS_UGPOST_DEBUG) == 1 } {
  return
   }

   global gPB
   if { [info exists gPB(PB_disable_MOM_pause)]  &&  $gPB(PB_disable_MOM_pause) == 1 } {
  return
   }



  #==========
  # Win64 OS
  #
   global tcl_platform

   if { [string match "*windows*" $tcl_platform(platform)] } {
      global mom_sys_processor_archit

      if { ![info exists mom_sys_processor_archit] } {
         set pVal ""
         set env_vars [array get env]
         set idx [lsearch $env_vars "PROCESSOR_ARCHITE*"]
         if { $idx >= 0 } {
            set pVar [lindex $env_vars $idx]
            set pVal [lindex $env_vars [expr $idx + 1]]
         }
         set mom_sys_processor_archit $pVal
      }

      if { [string match "*64*" $mom_sys_processor_archit] } {

         PAUSE_win64 $args
  return
      }
   }



   set cam_aux_dir  [MOM_ask_env_var UGII_CAM_AUXILIARY_DIR]


   if { [string match "*windows*" $tcl_platform(platform)] } {
     set ug_wish "ugwish.exe"
   } else {
     set ug_wish ugwish
   }

   if { [file exists ${cam_aux_dir}$ug_wish] && [file exists ${cam_aux_dir}mom_pause.tcl] } {

      set title ""
      set msg ""

      if { [llength $args] == 1 } {
         set msg [lindex $args 0]
      }

      if { [llength $args] > 1 } {
         set title [lindex $args 0]
         set msg [lindex $args 1]
      }

      set res [exec ${cam_aux_dir}$ug_wish ${cam_aux_dir}mom_pause.tcl $title $msg]
      switch $res {
         no {
            set gPB(PB_disable_MOM_pause) 1
         }
         cancel {
            set gPB(PB_disable_MOM_pause) 1

            uplevel #0 {
               MOM_abort "*** User Abort Post Processing *** "
            }
         }
         default { return }
      }
   }
}


#=============================================================
proc STR_MATCH { VAR str {out_warn 0} } {
#=============================================================
# This command will match a variable with a given string.
#
# - Users can set the optional flag "out_warn" to "1" to produce
#   warning message when the variable is not defined in the scope
#   of the caller of this function.
#
   upvar $VAR var

   if { [info exists var] && [string match "$var" "$str"] } {
return 1
   } else {
      if { $out_warn } {
         CATCH_WARNING "Variable $VAR is not defined in \"[lindex [info level -1] 0]\"!"
      }
return 0
   }
}


#=============================================================
proc TRACE { {up_level 0} } {
#=============================================================
# "up_level" to be a negative integer
#
   set start_idx 1

   set str ""
   set level [expr [info level] - int(abs($up_level))]

   for { set i $start_idx } { $i <= $level } { incr i } {
      if { $i < $level } {
         set str "${str}[lindex [info level $i] 0]\n"
      } else {
         set str "${str}[lindex [info level $i] 0]"
      }
   }

return $str
}


#=============================================================
proc UNSET_VARS { args } {
#=============================================================
# Inputs: List of variable names
#

   if { [llength $args] == 0 } {
return
   }

   foreach VAR $args {

      set VAR [string trim $VAR]
      if { $VAR != "" } {

         upvar $VAR var

         if { [array exists var] } {
            if { [expr $::tcl_version > 8.1] } {
               array unset var
            } else {
               foreach a [array names var] {
                  if { [info exists var($a)] } {
                     unset var($a)
                  }
               }
               unset var
            }
         }

         if { [info exists var] } {
            unset var
         }

      }
   }
}


#=============================================================
proc VMOV { n p1 p2 } {
#=============================================================
  upvar $p1 v1 ; upvar $p2 v2

   for { set i 0 } { $i < $n } { incr i } {
      set v2($i) $v1($i)
   }
}


#=============================================================
proc WORKPLANE_SET { } {
#=============================================================
   global mom_cycle_spindle_axis
   global mom_sys_spindle_axis
   global traverse_axis1 traverse_axis2

   if { ![info exists mom_sys_spindle_axis] } {
      set mom_sys_spindle_axis(0) 0.0
      set mom_sys_spindle_axis(1) 0.0
      set mom_sys_spindle_axis(2) 1.0
   }

   if { ![info exists mom_cycle_spindle_axis] } {
      set x $mom_sys_spindle_axis(0)
      set y $mom_sys_spindle_axis(1)
      set z $mom_sys_spindle_axis(2)

      if { [EQ_is_zero $y] && [EQ_is_zero $z] } {
         set mom_cycle_spindle_axis 0
      } elseif { [EQ_is_zero $x] && [EQ_is_zero $z] } {
         set mom_cycle_spindle_axis 1
      } else {
         set mom_cycle_spindle_axis 2
      }
   }

   if { $mom_cycle_spindle_axis == 2 } {
      set traverse_axis1 0 ; set traverse_axis2 1
   } elseif { $mom_cycle_spindle_axis == 0 } {
      set traverse_axis1 1 ; set traverse_axis2 2
   } elseif { $mom_cycle_spindle_axis == 1 } {
      set traverse_axis1 0 ; set traverse_axis2 2
   }
}


#=============================================================
proc PB_load_alternate_unit_settings { } {
#=============================================================
   global mom_output_unit mom_kin_output_unit

  # Skip this function when output unit agrees with post unit.
   if { ![info exists mom_output_unit] } {
      set mom_output_unit $mom_kin_output_unit
return
   } elseif { ![string compare $mom_output_unit $mom_kin_output_unit] } {
return
   }


   global mom_event_handler_file_name

  # Set unit conversion factor
   if { ![string compare $mom_output_unit "MM"] } {
      set factor 25.4
   } else {
      set factor [expr 1/25.4]
   }

  # Define unit dependent variables list
   set unit_depen_var_list [list mom_kin_x_axis_limit mom_kin_y_axis_limit mom_kin_z_axis_limit \
                                 mom_kin_pivot_gauge_offset mom_kin_ind_to_dependent_head_x \
                                 mom_kin_ind_to_dependent_head_z]

   set unit_depen_arr_list [list mom_kin_4th_axis_center_offset \
                                 mom_kin_5th_axis_center_offset \
                                 mom_kin_machine_zero_offset \
                                 mom_kin_4th_axis_point \
                                 mom_kin_5th_axis_point \
                                 mom_sys_home_pos]

  # Load unit dependent variables
   foreach var $unit_depen_var_list {
      if { ![info exists $var] } {
         global $var
      }
      if { [info exists $var] } {
         set $var [expr [set $var] * $factor]
         MOM_reload_variable $var
      }
   }

   foreach var $unit_depen_arr_list {
      if { ![info exists $var] } {
         global $var
      }
      foreach item [array names $var] {
         if { [info exists ${var}($item)] } {
            set ${var}($item) [expr [set ${var}($item)] * $factor]
         }
      }

      MOM_reload_variable -a $var
   }


  # Source alternate unit post fragment
   uplevel #0 {
      global mom_sys_alt_unit_post_name
      set alter_unit_post_name \
          "[file join [file dirname $mom_event_handler_file_name] [file rootname $mom_sys_alt_unit_post_name]].tcl"

      if { [file exists $alter_unit_post_name] } {
         source "$alter_unit_post_name"
      }
      unset alter_unit_post_name
   }

   if { [llength [info commands PB_load_address_redefinition]] > 0 } {
      PB_load_address_redefinition
   }

   MOM_reload_kinematics
}


if [info exists mom_sys_start_of_program_flag] {
   if [llength [info commands PB_CMD_kin_start_of_program] ] {
      PB_CMD_kin_start_of_program
   }
} else {
   set mom_sys_head_change_init_program 1
   set mom_sys_start_of_program_flag 1
}


set cam_post_user_tcl "new_post_user.tcl"




#***************************
# Source in user's tcl file.
#***************************
set cam_post_dir [MOM_ask_env_var UGII_CAM_POST_DIR]
set ugii_version [string trimleft [MOM_ask_env_var UGII_VERSION] v]

if { [catch {
   if { $ugii_version >= 5 } {
      if { [file exists "[file dirname [info script]]/$cam_post_user_tcl"] } {
        # From directory relative to that of current post
         source "[file dirname [info script]]/$cam_post_user_tcl"
      } elseif { [file exists "${cam_post_dir}$cam_post_user_tcl"] } {
        # From directory relative to UGII_CAM_POST_DIR
         source "${cam_post_dir}$cam_post_user_tcl"
      } elseif { [file exists "$cam_post_user_tcl"] } {
        # From the specified directory
         source "$cam_post_user_tcl"
      } else {
         MOM_output_to_listing_device "User's Tcl: $cam_post_user_tcl not found!"
      }
   } else {
      if { [file exists "${cam_post_dir}$cam_post_user_tcl"] } {
         source "${cam_post_dir}$cam_post_user_tcl"
      } else {
         MOM_output_to_listing_device "User's Tcl: ${cam_post_dir}$cam_post_user_tcl not found!"
      }
   }
} err] } {
   MOM_output_to_listing_device "User's Tcl: An error occured while sourcing $cam_post_user_tcl!\n$err"
   MOM_abort "User's Tcl: An error occured while sourcing $cam_post_user_tcl!\n$err"
}


