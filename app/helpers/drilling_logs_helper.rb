module DrillingLogsHelper

    include ActionView::Helpers::NumberHelper

    def fill_drilling_report job, entries, r, start_time, end_time
        drilling_log = DrillingLog.calculate entries
        issues = Issue.includes(job: :well).where("wells.id = ?", job.well_id).where("issues.failure_at >= :start_time AND issues.failure_at <= :end_time", start_time: start_time, end_time: end_time)

        r.add_field "JOB_NAME", job.field.name + ' - ' + job.well.name
        r.add_field "JOB_NUMBER", 'Job # ' + (job.job_number || '-')
        r.add_field "RIG", 'Rig ' + (job.well.rig.present? ? job.well.rig.name : '-')
        r.add_field "CLIENT", job.company.name
        hours = (end_time - start_time).to_f / 60.0 / 60.0
        if hours <= 24
            r.add_field "TIME", "#{start_time.strftime('%m/%d/%Y')} (#{hours.ceil.to_i} hours)"
        else
            r.add_field "TIME", "#{start_time.strftime('%m/%d/%Y')} - #{end_time.strftime('%m/%d/%Y')} (#{(hours / 24.0).round(0).to_i} days)"
        end

        r.add_field "T1", drilling_log.rop.nil? ? "-" : drilling_log.rop.round(1)
        r.add_field "T2", drilling_log.total_drilled.nil? ? "-" : number_with_delimiter(drilling_log.total_drilled.to_i, :delimiter => ',')
        r.add_field "T3", drilling_log.drilling_time.nil? ? "-" : drilling_log.drilling_time.round(1)
        r.add_field "T4", drilling_log.total_circulation_time.nil? ? "-" : drilling_log.total_circulation_time.round(1)
        r.add_field "T5", issues.count
        r.add_field "T6", "#{number_with_delimiter(entries.first.depth.to_i, :delimiter => ',')} - #{number_with_delimiter(entries.last.depth.to_i, :delimiter => ',')}"

        bhas = entries.select { |e| e.bha.present? }.group_by { |e| e.bha_id }
        r.add_field "T7", bhas.count

        runs = DrillingLog.new.get_runs(entries)
        r.add_field "T8", runs.count

        r.add_field "C1", "-"
        r.add_field "C2", "-"


        r.add_field "R1", drilling_log.rotary_footage_pct.nil? ? "-" : drilling_log.rotary_footage_pct.round(1)
        r.add_field "R2", drilling_log.rotary_hours_pct.nil? ? "-" : drilling_log.rotary_hours_pct.round(1)
        r.add_field "R3", drilling_log.rotate_rop.nil? ? "-" : drilling_log.rotate_rop.round(1)
        r.add_field "R4", drilling_log.rotate_footage.nil? ? "-" : number_with_delimiter(drilling_log.rotate_footage.to_i, :delimiter => ',')
        r.add_field "R5", drilling_log.rotate_hours.nil? ? "-" : drilling_log.rotate_hours.round(1)

        r.add_field "S1", drilling_log.slide_footage_pct.nil? ? "-" : drilling_log.slide_footage_pct.round(1)
        r.add_field "S2", drilling_log.slide_hours_pct.nil? ? "-" : drilling_log.slide_hours_pct.round(1)
        r.add_field "S3", drilling_log.slide_rop.nil? ? "-" : drilling_log.slide_rop.round(1)
        r.add_field "S4", drilling_log.slide_footage.nil? ? "-" : number_with_delimiter(drilling_log.slide_footage.to_i, :delimiter => ',')
        r.add_field "S5", drilling_log.slide_hours.nil? ? "-" : drilling_log.slide_hours.round(1)

        bhas.each_with_index do |bha_group, index|
            bha = Bha.find_by_id(bha_group[0])
            bha_entries = bha_group[1]
            r.add_field "BHA#{index + 1}", "BHA #{bha.name}"
            r.add_field "BHA#{index + 1}_DESC", "#{bha.description}"
            r.add_field "B#{index + 1}_TIME", "#{bha_entries.first.entry_at.strftime('%m/%d %H:%M %p')} - #{bha_entries.last.entry_at.strftime('%m/%d %H:%M %p')}"
        end

        if bhas.count < 3
            r.add_field "BHA3", ""
            r.add_field "BHA3_DESC", ""
            r.add_field "B3_TIME", ""
        end
        if bhas.count < 2
            r.add_field "BHA2", ""
            r.add_field "BHA2_DESC", ""
            r.add_field "B2_TIME", ""
        end


        r.add_field "H1", "Drilling Parameters"
        r.add_field "P1", "Start Depth"
        r.add_field "V1", "#{drilling_log.start_depth.to_i} ft"
        r.add_field "P2", "End Depth"
        r.add_field "V2", "#{drilling_log.end_depth.to_i} ft"
        r.add_field "P3", "In-Hole"
        r.add_field "V3", "#{drilling_log.below_rotary.round(1)} hrs"
        r.add_field "P4", "Out-Hole"
        r.add_field "V4", "#{drilling_log.above_rotary.round(1)} hrs"
        r.add_field "P5", "Circulation"
        r.add_field "V5", "#{drilling_log.circulation_hours.round(1)} hrs"
        r.add_field "P6", "Reaming"
        r.add_field "V6", "#{drilling_log.ream_hours.round(1)} hrs"

        r.add_field "P7", "WOB"
        r.add_field "V7", "#{drilling_log.ranges["wob_min"]} - #{drilling_log.ranges["wob_max"]} lbs"
        r.add_field "P8", "Rotate Weight"
        r.add_field "V8", "#{drilling_log.ranges["rotary_weight_min"]} - #{drilling_log.ranges["rotary_weight_max"]} lbs"
        r.add_field "P9", "P/U Weight"
        r.add_field "V9", "#{drilling_log.ranges["pu_weight_min"]} - #{drilling_log.ranges["pu_weight_max"]} lbs"
        r.add_field "P10", "S/O Weight"
        r.add_field "V10", "#{drilling_log.ranges["so_weight_min"]} - #{drilling_log.ranges["so_weight_max"]} lbs"
        r.add_field "P11", "SPP"
        r.add_field "V11", "#{drilling_log.ranges["spp_min"]} - #{drilling_log.ranges["spp_max"]} psi"
        r.add_field "P12", "Flow Rate"
        r.add_field "V12", "#{drilling_log.ranges["flow_min"]} - #{drilling_log.ranges["flow_max"]} g/m"

        r.add_field "P13", "Rotary RPM"
        r.add_field "V13", "#{drilling_log.ranges["rotary_rpm_min"]} - #{drilling_log.ranges["rotary_rpm_max"]} rpm"
        r.add_field "P14", "Motor RPM"
        r.add_field "V14", "#{drilling_log.ranges["motor_rpm_min"]} - #{drilling_log.ranges["motor_rpm_max"]} rpm"
        r.add_field "P15", "Torque"
        r.add_field "V15", "#{drilling_log.ranges["torque_min"]} - #{drilling_log.ranges["torque_max"]}"
        r.add_field "P16", "Avg Diff Pressure"
        r.add_field "V16", "#{drilling_log.ranges["diff_pressure_min"]} - #{drilling_log.ranges["diff_pressure_max"]} psi"
        r.add_field "P17", "Stall Pressure"
        r.add_field "V17", "#{drilling_log.ranges["stall_min"]} - #{drilling_log.ranges["stall_max"]} psi"
        r.add_field "P18", ""
        r.add_field "V18", ""

        r.add_field "H2", "Mud Parameters"
        r.add_field "PP1", "Mud Type"
        r.add_field "VV1", "#{drilling_log.ranges["mud_type_min"]} - #{drilling_log.ranges["mud_type_max"]}"
        r.add_field "PP2", "Mud Weight"
        r.add_field "VV2", "#{drilling_log.ranges["mud_weight_min"]} - #{drilling_log.ranges["mud_weight_max"]} lbs"
        r.add_field "PP3", "Viscosity"
        r.add_field "VV3", "#{drilling_log.ranges["viscosity_min"]} - #{drilling_log.ranges["viscosity_max"]}"
        r.add_field "PP4", "Chlorides"
        r.add_field "VV4", "#{drilling_log.ranges["chlorides_min"]} - #{drilling_log.ranges["chlorides_max"]}"
        r.add_field "PP5", "Water Loss"
        r.add_field "VV5", "#{drilling_log.ranges["water_loss_min"]} - #{drilling_log.ranges["water_loss_max"]}"

        r.add_field "PP6", "YP"
        r.add_field "VV6", "#{drilling_log.ranges["yp_min"]} - #{drilling_log.ranges["yp_max"]}"
        r.add_field "PP7", "PV"
        r.add_field "VV7", "#{drilling_log.ranges["pv_min"]} - #{drilling_log.ranges["pv_max"]}"
        r.add_field "PP8", "PH"
        r.add_field "VV8", "#{drilling_log.ranges["ph_min"]} - #{drilling_log.ranges["ph_max"]}"
        r.add_field "PP9", "BH Temp"
        r.add_field "VV9", "#{drilling_log.ranges["bh_temp_min"]} - #{drilling_log.ranges["bh_temp_max"]}"
        r.add_field "PP10", "Flow Line Temp"
        r.add_field "VV10", "#{drilling_log.ranges["fl_temp_min"]} - #{drilling_log.ranges["fl_temp_max"]}"

        r.add_field "PP11", "Gas %"
        r.add_field "VV11", "#{drilling_log.ranges["gas_min"]} - #{drilling_log.ranges["gas_max"]}"
        r.add_field "PP12", "Sand %"
        r.add_field "VV12", "#{drilling_log.ranges["sand_min"]} - #{drilling_log.ranges["sand_max"]}"
        r.add_field "PP13", "Solids %"
        r.add_field "VV13", "#{drilling_log.ranges["solids_min"]} - #{drilling_log.ranges["solids_max"]}"
        r.add_field "PP14", "Oil %"
        r.add_field "VV14", "#{drilling_log.ranges["oil_min"]} - #{drilling_log.ranges["oil_max"]}"
        r.add_field "PP15", ""
        r.add_field "VV15", ""

        r.add_field "H3", "Pumps"
        r.add_field "PPP1", "Liner Size"
        r.add_field "VVV1", "-"
        r.add_field "PPP2", "Stroke Length"
        r.add_field "VVV2", "-"
        r.add_field "PPP3", "Gallons/Stroke"
        r.add_field "VVV3", "-"
        r.add_field "PPP4", "Barrels/Stroke"
        r.add_field "VVV4", "-"
        r.add_field "PPP5", "Efficiency"
        r.add_field "VVV5", ""
        r.add_field "PPP6", ""
        r.add_field "VVV6", ""

        r.add_field "H4", "MWD"
        r.add_field "PPP7", "Battery 1 Amps"
        r.add_field "VVV7", "#{drilling_log.ranges["battery_1_amps_min"]} - #{drilling_log.ranges["battery_1_amps_max"]} amps"
        r.add_field "PPP8", "Battery 2 Amps"
        r.add_field "VVV8", "#{drilling_log.ranges["battery_2_amps_min"]} - #{drilling_log.ranges["battery_2_amps_max"]} amps"
        r.add_field "PPP9", "Battery Volts"
        r.add_field "VVV9", "#{drilling_log.ranges["battery_volts_min"]} - #{drilling_log.ranges["battery_volts_max"]} volts"
    end


    def fill_log job, entries, r, start_time, end_time
        r.add_field "JOB_NAME", job.field.name + ' - ' + job.well.name
        r.add_field "JOB_NUMBER", 'Job # ' + (job.job_number || '-')
        r.add_field "RIG", 'Rig ' + (job.well.rig.present? ? job.well.rig.name : '-')
        r.add_field "CLIENT", job.company.name
        hours = (end_time - start_time).to_f / 60.0 / 60.0
        if hours <= 24
            r.add_field "TIME_SPAN", "#{start_time.strftime('%m/%d/%Y')} (#{hours.ceil.to_i} hours)"
        else
            r.add_field "TIME_SPAN", "#{start_time.strftime('%m/%d/%Y')} - #{end_time.strftime('%m/%d/%Y')} (#{(hours / 24.0).round(0).to_i} days)"
        end

        last_entry = entries.first
        index = 0
        entries.each_with_index do |entry, i|
            entry.last_entry =  last_entry
            last_entry = entry
        end

        last_entry = entries.first
        r.add_table("TABLE", entries, :header => false) do |t|
            t.add_column("TIME") do |entry|
                "#{entry.entry_at.strftime("%H:%M %p")}"
            end
            t.add_column("SPAN") do |entry|
                "#{((entry.entry_at - entry.last_entry.entry_at) / 60 / 60).round(2)} hrs"
            end
            t.add_column("DEPTH") { |entry| "#{number_with_delimiter(entry.depth, :delimiter => ',')}" }
            t.add_column("DELTA") do |entry|
                "(#{entry.depth - entry.last_entry.depth})"
            end
            t.add_column("ACTIVITY") { |entry| "#{DrillingLogEntry.activity_code_string(entry.activity_code)}" }
            t.add_column("COMMENT") { |entry| "#{entry.comment}" }
            t.add_column("BHA") { |entry| "#{entry.bha.present? ? entry.bha.name : ''}" }
        end
    end

end
