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
        r.add_field "T3", drilling_log.rop.nil? ? "-" : drilling_log.drilling_time.round(1)
        r.add_field "T4", drilling_log.rop.nil? ? "-" : drilling_log.total_circulation_time.round(1)
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
        r.add_field "V7", "#{drilling_log.low_wob.to_i} - #{drilling_log.high_wob.to_i} lbs"
        r.add_field "P8", "Rotate Weight"
        r.add_field "V8", "-"
        r.add_field "P9", "P/U Weight"
        r.add_field "V9", "-"
        r.add_field "P10", "S/O Weight"
        r.add_field "V10", "-"
        r.add_field "P11", "SPP"
        r.add_field "V11", "-"
        r.add_field "P12", "Flow Rate"
        r.add_field "V12", "#{drilling_log.low_flow.to_i} - #{drilling_log.high_flow.to_i} lbs"

        r.add_field "P13", "Rotary RPM"
        r.add_field "V13", "-"
        r.add_field "P14", "Motor RPM"
        r.add_field "V14", "-"
        r.add_field "P15", "Torque"
        r.add_field "V15", "-"
        r.add_field "P16", "Avg Diff Pressure"
        r.add_field "V16", "-"
        r.add_field "P17", "Stall Pressure"
        r.add_field "V17", "-"
        r.add_field "P18", ""
        r.add_field "V18", ""

        r.add_field "H2", "Mud Parameters"
        r.add_field "PP1", "Mud Type"
        r.add_field "VV1", "-"
        r.add_field "PP2", "Mud Weight"
        r.add_field "VV2", "-"
        r.add_field "PP3", "Viscosity"
        r.add_field "VV3", "-"
        r.add_field "PP4", "Chlorides"
        r.add_field "VV4", "-"
        r.add_field "PP5", "Water Loss"
        r.add_field "VV5", "-"

        r.add_field "PP6", "YP"
        r.add_field "VV6", "-"
        r.add_field "PP7", "PV"
        r.add_field "VV7", "-"
        r.add_field "PP8", "PH"
        r.add_field "VV8", "-"
        r.add_field "PP9", "BH Temp"
        r.add_field "VV9", "-"
        r.add_field "PP10", "Flow Line Temp"
        r.add_field "VV10", "-"

        r.add_field "PP11", "Gas %"
        r.add_field "VV11", "-"
        r.add_field "PP12", "Sand %"
        r.add_field "VV12", "-"
        r.add_field "PP13", "Solids %"
        r.add_field "VV13", "-"
        r.add_field "PP14", "Oil %"
        r.add_field "VV14", "-"
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

        r.add_field "H4", ""
        r.add_field "PPP7", ""
        r.add_field "VVV7", ""
        r.add_field "PPP8", ""
        r.add_field "VVV8", ""
        r.add_field "PPP9", ""
        r.add_field "VVV9", ""
    end


end
