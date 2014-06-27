class WitsRecord < ActiveRecord::Base
    attr_accessible :entry_at,
                    :bit_depth,
                    :hole_depth,
                    :min_convertible_torque,
                    :hook_load,
                    :standpipe_pressure,
                    :rotary_rpm,
                    :rotary_torque,
                    :weight_on_bit,
                    :on_bottom_rop,
                    :flow,
                    :total_mud_volume,
                    :trip_tank_mud_volume,
                    :line_wear,
                    :casing_pressure,
                    :pump1_rate,
                    :pump2_rate,
                    :pump3_rate,
                    :pump4_rate,
                    :pump1_total_strokes,
                    :pump2_total_strokes,
                    :pump3_total_strokes,
                    :pump4_total_strokes,
                    :total_strokes,
                    :total_pump_output,
                    :total_pump_displacement,
                    :block_height,
                    :mud_tank1_volume,
                    :mud_tank2_volume,
                    :mud_tank3_volume,
                    :mud_tank4_volume,
                    :mud_tank5_volume,
                    :on_bottom_hours,
                    :circulating_hours,
                    :explosive_gas1,
                    :explosive_gas2,
                    :tool_face,
                    :inclination,
                    :azimuth,
                    :gamma,
                    :mud_gl_alarm_state,
                    :flow_1_gl_alarm_state,
                    :magnetic_tool_face,
                    :gravity_tool_face,
                    :mwd_vibration_xyz,
                    :mwd_temperature,
                    :mwd_general_variable1,
                    :mwd_general_variable2,
                    :mwd_general_variable3,
                    :mwd_general_variable4,
                    :mwd_vibration_xyz_gamma,
                    :mwd_vibration_xy_gamma,
                    :mwd_vibration_z_gamma,
                    :over_pull,
                    :fill_strokes,
                    :total_fill_strokes,
                    :min_pressure,
                    :min_hook_load,
                    :min_torque,
                    :min_rpm,
                    :min_wob,
                    :relative_mse,
                    :cement_fluid_temp,
                    :mwd_vibration_count,
                    :sensor_depth,
                    :pvt_total_mud_gain_loss,
                    :differential_pressure,
                    :pason_lag_depth,
                    :tts_weight_on_bit,
                    :drilling_activity,
                    :min_tts_weight_on_bit,
                    :choke_position,
                    :trip_speed,
                    :gamma_depth,
                    :gamma_at_bit,
                    :resistivity2,
                    :formation_density,
                    :res2_at_bit,
                    :fdens_at_bit,
                    :percent_wits_gas,
                    :motor_rpm,
                    :convertible_torque,
                    :p1_rate,
                    :p2_rate,
                    :pvt_mud_tanks_included,
                    :pvt_monitor_mud_gl,
                    :pvt_mud_gl_threshold,
                    :trip_tank_1_refill_status,
                    :trip_tank_1_low_threshold,
                    :trip_tank_1_high_threshold,
                    :flow_1_gl,
                    :flow_1_gl_threshold,
                    :xy_accel_severity_level,
                    :z_accel_severity_level,
                    :trip_tank_fill,
                    :trip_tank_accum,
                    :rate_of_penetration,
                    :time_of_penetration,
                    :autodriller_status,
                    :autodriller_sensitivity,
                    :autodriller_drum_ticks,
                    :autodriller_wob,
                    :autodriller_wob_sp,
                    :autodriller_brake_pos,
                    :autodriller_diff_press,
                    :autodriller_diff_press_sp,
                    :autodriller_torque,
                    :autodriller_torque_limit,
                    :autodriller_status_uw,
                    :autodriller_status_lw,
                    :autodriller_status_2_uw,
                    :autodriller_status_2_lw,
                    :autodriller_timedrill_sp,
                    :autodriller_rop_sp,
                    :autodriller_ticks_per_depth

    belongs_to :company
    belongs_to :job
end
