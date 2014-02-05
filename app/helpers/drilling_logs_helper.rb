module DrillingLogsHelper

    include ActionView::Helpers::NumberHelper

    def fill_run_report job, entries, r, start_time, end_time, run_number
        fill_drilling_report job, entries, r, start_time, end_time

        if run_number == 0
            r.add_field "RUN_NAME", "ALL RUNS"
        else
            r.add_field "RUN_NAME", "RUN #{run_number}"
        end

        bhas = entries.select { |e| e.bha.present? }.group_by { |e| e.bha_id }
        if bhas.count == 1 && bhas[0].present?
            r.add_field "BHA1", "#{bhas[0].name}"
            r.add_field "BHA1_DESC", "#{bhas[0].description}"
        else
            r.add_field "BHA1", "-"
            r.add_field "BHA1_DESC", ""
        end
    end

    def fill_bha_report job, entries, r, start_time, end_time, bha, run_number
        fill_drilling_report job, entries, r, start_time, end_time

        r.add_field "BHA_NAME", "BHA # #{bha.name} - #{bha.description}"
        r.add_field "RUN", "#{run_number}"


        last_index = 0
        depth = 0.0
        bha.bha_items.each_with_index do |bha_item, index|
            if bha_item.tool.present?
                depth = depth + (bha_item.tool.length || 0)
                r.add_field "A#{index + 1}", "#{bha_item.tool.name}"
                r.add_field "ID#{index + 1}", "#{bha_item.tool.inner_diameter}"
                r.add_field "OD#{index + 1}", "#{bha_item.tool.outer_diameter}"
                r.add_field "L#{index + 1}", "#{bha_item.tool.length}"
                r.add_field "LT#{index + 1}", "#{depth.round(2)}"
                r.add_field "TC#{index + 1}", "#{bha_item.up >= 0 ? BhaItem.connection_string(bha_item.up) : "-"}"
            end
            last_index = index
        end

        (11 - last_index).times do
            last_index = last_index + 1
            r.add_field "A#{last_index + 1}", ""
            r.add_field "ID#{last_index + 1}", ""
            r.add_field "OD#{last_index + 1}", ""
            r.add_field "L#{last_index + 1}", ""
            r.add_field "LT#{last_index + 1}", ""
            r.add_field "TC#{last_index + 1}", ""
        end
    end

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
        r.add_field "T6", "#{number_with_delimiter(drilling_log.start_depth.to_i, :delimiter => ',')} - #{number_with_delimiter(drilling_log.end_depth.to_i, :delimiter => ',')}"

        bhas = entries.select { |e| e.bha.present? }.group_by { |e| e.bha_id }
        r.add_field "T7", bhas.count

        runs = DrillingLog.new.get_runs(entries)
        r.add_field "T8", runs.count

        r.add_field "C1", "-"
        r.add_field "C2", "-"


        r.add_field "R1", drilling_log.rotary_footage_pct.nil? ? "-" : (drilling_log.rotary_footage_pct * 100).round(1)
        r.add_field "R2", drilling_log.rotary_hours_pct.nil? ? "-" : (drilling_log.rotary_hours_pct * 100).round(1)
        r.add_field "R3", drilling_log.rotate_rop.nil? ? "-" : drilling_log.rotate_rop.round(1)
        r.add_field "R4", drilling_log.rotate_footage.nil? ? "-" : number_with_delimiter(drilling_log.rotate_footage.to_i, :delimiter => ',')
        r.add_field "R5", drilling_log.rotate_hours.nil? ? "-" : drilling_log.rotate_hours.round(1)

        r.add_field "S1", drilling_log.slide_footage_pct.nil? ? "-" : (drilling_log.slide_footage_pct * 100).round(1)
        r.add_field "S2", drilling_log.slide_hours_pct.nil? ? "-" : (drilling_log.slide_hours_pct * 100).round(1)
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
        r.add_field "V3", "#{drilling_log.below_rotary.present? ? drilling_log.below_rotary.round(1) : 0.0} hrs"
        r.add_field "P4", "Out-Hole"
        r.add_field "V4", "#{drilling_log.above_rotary.present? ? drilling_log.above_rotary.round(1) : 0.0} hrs"
        r.add_field "P5", "Circulation"
        r.add_field "V5", "#{drilling_log.circulation_hours.present? ? drilling_log.circulation_hours.round(1) : 0.0} hrs"
        r.add_field "P6", "Reaming"
        r.add_field "V6", "#{drilling_log.ream_hours.present? ? drilling_log.ream_hours.round(1) : 0.0} hrs"

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
            entry.last_entry = last_entry
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


    def fill_survey job, entries, r
        r.add_field "JOB_NAME", job.field.name + ' - ' + job.well.name
        r.add_field "JOB_NUMBER", 'Job # ' + (job.job_number || '-')
        r.add_field "RIG", 'Rig ' + (job.well.rig.present? ? job.well.rig.name : '-')
        r.add_field "CLIENT", job.company.name

        if false
            new_entries = []
            entries.each do |e|
                e.instance_eval do
                    def comment_line
                        instance_variable_get("@comment_line")
                    end

                    def comment_line=(val)
                        instance_variable_set("@comment_line", val)
                    end
                end

                e.comment_line = false

                if !e.comment.blank?
                    new_sp = e.clone
                    new_sp.comment_line = true
                    new_entries << e
                end

                new_entries << e
            end
        end

        r.add_table("TABLE", entries, :header => false) do |t|
            t.add_column("DEPTH") do |entry|
                "#{number_with_delimiter(entry.measured_depth.round(2), :delimiter => ',')}"
            end
            t.add_column("INC") do |entry|
                "#{entry.inclination}"
            end
            t.add_column("AZI") do |entry|
                "#{entry.azimuth}"
            end
            t.add_column("TVD") { |entry| "#{number_with_delimiter(entry.true_vertical_depth.round(2), :delimiter => ',')}" }

            t.add_column("VSECT") do |entry|
                "#{entry.vertical_section.round(2)}"
            end
            t.add_column("NS") { |entry| "#{entry.north_south.round(2)}" }
            t.add_column("EW") { |entry| "#{entry.east_west.round(2)}" }
            t.add_column("DLS") { |entry| "#{entry.dog_leg_severity.present? ? entry.dog_leg_severity.round(2) : '-'}" }
        end
    end


    def fill_railroad job, well_plan, entries, r
        r.add_field "ADDRESS_1", "12491 North Freeway Suite 400"
        r.add_field "ADDRESS_2", "Houston, TX 77060"
        r.add_field "TODAY", Date.today.strftime("%B %d, %Y")
        r.add_field "NAME", "Ralph Clarke"
        r.add_field "TITLE", "VP MWD Operations"
        r.add_field "COMPANY", "Premier Directional Drilling, LLC"
        r.add_field "CLIENT", job.client.name

        r.add_field "WELL_NAME", job.well.name

        hours = (entries.last.created_at - entries.first.created_at).to_f / 60.0 / 60.0
        if hours <= 24
            r.add_field "DATE", Date.today.strftime("%B %d, %Y")
        else
            r.add_field "DATE", "#{entries.first.strftime("%B %d, %Y")} - #{entries.last.strftime("%B %d, %Y")}"
        end

        r.add_field "START", entries.first.measured_depth
        r.add_field "END", entries.last.measured_depth
    end

    def fill_railroad_certification job, drilling_log, well_plan, survey, entries, r
        r.add_field "ADDRESS_1", "12491 North Freeway Suite 400"
        r.add_field "ADDRESS_2", "Houston, TX 77060"
        r.add_field "TODAY", Date.today.strftime("%B %d, %Y")
        r.add_field "NAME", "Ralph Clarke"
        r.add_field "TITLE", "VP MWD Operations"
        r.add_field "COMPANY", "Premier Directional Drilling, LLC"
        r.add_field "CLIENT", job.client.name
        r.add_field "OP_NO", "676020"
        r.add_field "DATE", Date.today.strftime("%B %d, %Y")

        r.add_field "NAMES", "-"

        r.add_field "JOB_NUMBER", job.job_number.present? ? job.job_number : '-'
        r.add_field "API_NUMBER", job.api_number.present? ? job.api_number : '-'
        r.add_field "WELL_NAME", job.well.name
        r.add_field "COUNTY", "#{job.field.county}, #{job.field.state.name}"

        if survey.present?
            type = drilling_log.drilling_log_entries.where("drilling_log_entries.mwd_type IS NOT NULL").last
            r.add_field "JOB_TYPE", type.present? && type.mwd_type == 1 ? "Electromagnetic" : "Pulse"
            r.add_field "VS_AZIMUTH", "#{well_plan.present? ? well_plan.vertical_section_azimuth : '-'}"
            r.add_field "CORRECTION", "#{survey.total_correction}"
            r.add_field "NORTH_TYPE", survey.north_type == Survey::GRID ? "GRID" : (survey.north_type == Survey::TRUE ? "TRUE" : "MAGNETIC")

            tie_in = entries.first
            r.add_field "TIE_IN_MD", "#{tie_in.measured_depth}"
            r.add_field "TIE_IN_TVD", "#{tie_in.true_vertical_depth}"
            r.add_field "TIE_IN_INC", "#{tie_in.inclination}"
            r.add_field "TIE_IN_AZI", "#{tie_in.azimuth}"
            r.add_field "TIE_IN_NS", "#{tie_in.north_south}"
            r.add_field "TIE_IN_EW", "#{tie_in.east_west}"

            first = entries[1]
            r.add_field "D1", "#{first.measured_depth}"
            r.add_field "INC1", "#{first.inclination}"
            r.add_field "AZI1", "#{first.azimuth}"
            r.add_field "DATE1", "#{first.created_at.strftime("%d/%m/%Y")}"

            last = entries.last
            r.add_field "D2", "#{last.measured_depth}"
            r.add_field "INC2", "#{last.inclination}"
            r.add_field "AZI2", "#{last.azimuth}"
            r.add_field "DATE2", "#{last.created_at.strftime("%d/%m/%Y")}"

            bha = drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id IS NOT NULL").last
            r.add_field "D3", "#{last.measured_depth + (bha.present? && bha.bha.present? && bha.bha.bit_to_sensor.present? ? bha.bha.bit_to_sensor : 0.0)}"
            r.add_field "INC3", "#{last.inclination}"
            r.add_field "AZI3", "#{last.azimuth}"
        end
    end

    def drilling_log_to_excel drilling_log
        p = Axlsx::Package.new
        wb = p.workbook

        wb.styles do |s|
            title_cell = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 16, :alignment => {:horizontal => :center}
            title_cell2 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :center}
            column_name_cell = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :sz => 12, :b => true, :alignment => {:horizontal => :left}, :border => {:style => :thin, :color => "00", :edges => [:top, :bottom]}

            cell1 = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}
            cell2 = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}
            cell1_bold = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :left}
            cell2_bold = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :left}

            date1 = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}, :format_code => "yyyy-mm-dd"
            date2 = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}, :format_code => "yyyy-mm-dd"

            margins = {:left => 1, :right => 1, :top => 1, :bottom => 1, :header => 0, :footer => 0}
            setup = {:fit_to_width => 1, :orientation => :portrait, :paper_width => "21cm", :paper_height => "29.7cm"}
            options = {:grid_lines => true, :headings => true, :horizontal_centered => true}

            wb.add_worksheet(:name => "Daily Activity", :page_margins => margins, :page_setup => setup, :print_options => options) do |sheet|
                sheet.add_row ['Daily Activity', '', '', '', ''], :style => title_cell
                sheet.add_row [drilling_log.document.job.field.name + ' | ' + drilling_log.document.job.well.name, '', '', '', ''], :style => title_cell
                sheet.add_row [drilling_log.document.job.well.rig.present? ? drilling_log.document.job.well.rig.name : '', '', '', '', ''], :style => title_cell
                sheet.add_row ['', '', '', '', ''], :style => title_cell


                sheet.add_row ['Date', 'Time', 'Depth', 'BHA #', 'Activity', 'Comments', 'WOB', 'GPM', 'RPM', 'TFO'], :style => column_name_cell

                drilling_log.drilling_log_entries.includes(:bha).each_with_index do |dl, index|
                    cell = index % 2 == 0 ? cell1 : cell2
                    bold = index % 2 == 0 ? cell1_bold : cell2_bold
                    date = index % 2 == 0 ? date1 : date2
                    sheet.add_row [dl.entry_at.strftime("%Y-%m-%d"), dl.entry_at.strftime("%k:%M"), dl.depth, dl.bha.present? ? dl.bha.name : '', get_activity_code_string(dl.activity_code), dl.comment, dl.wob, dl.flow, dl.rotary_rpm, dl.tfo], :style => [date, bold, bold, cell, bold, cell, cell, cell, cell, cell]
                end

                sheet.column_widths 15, 10, 10, 8, 30, 45, 7, 7, 7, 7

                sheet.merge_cells("A1:J1")
                sheet.merge_cells("A2:J2")
                sheet.merge_cells("A3:J3")
                sheet.merge_cells("A4:J4")

            end
        end

        p
    end

    def get_activity_code_string value
        case value
            when DrillingLogEntry::DRILLING
                "DRILLING"
            when DrillingLogEntry::SLIDING
                "SLIDING"
            when DrillingLogEntry::CIRCULATING
                "CIRCULATING"
            when DrillingLogEntry::CONNECTION_SURVEY
                "CONNECTION & SURVEY"
            when DrillingLogEntry::REAMING
                "REAMING"
            when DrillingLogEntry::CEMENTING
                "CEMENTING"
            when DrillingLogEntry::CHANGE_MUD
                "CHANGE MUD"
            when DrillingLogEntry::CHANGE_BHA
                "CHANGE BHA"
            when DrillingLogEntry::POOH
                "POOH"
            when DrillingLogEntry::SHORT_TRIP
                "SHORT TRIP"
            when DrillingLogEntry::TIH
                "TIH"
            when DrillingLogEntry::TIH_CIRCULATING
                "TIH CIRCULATING"
            when DrillingLogEntry::WIRELINE
                "WIRELINE"
            when DrillingLogEntry::WORK_PIPE
                "WORK PIPE"
            when DrillingLogEntry::BOP_DRILL
                "BOP DRILL"
            when DrillingLogEntry::MWD_SURVEY
                "MWD SURVEY"
            when DrillingLogEntry::LD_DP
                "L/D DP"
            when DrillingLogEntry::PU_DP
                "P/U DP"
            when DrillingLogEntry::DRILLING_CEMENT
                "DRILLING CEMENT"
            when DrillingLogEntry::LOGGING
                "LOGGING"
            when DrillingLogEntry::CONNECTION
                "CONNECTION"
            when DrillingLogEntry::JETTING
                "JETTING"

            when DrillingLogEntry::OTHER
                "UNDEFINED"
            when DrillingLogEntry::RIG_REPAIR
                "RIG REPAIR"
            when DrillingLogEntry::PIPE_STUCK
                "PIPE STUCK"
            when DrillingLogEntry::FISHING
                "FISHING"
            when DrillingLogEntry::RIG_SERVICE_INHOLE
                "RIG SERVICE INHOLE"
            when DrillingLogEntry::WAIT_ON_WEATHER
                "WAIT ON WEATHER"
            when DrillingLogEntry::TROUBLESHOOT_MWD
                "TROUBLESHOOT MWD"


            when DrillingLogEntry::NIPPLE_BOPS
                "NIPPLE U/D BOPS"
            when DrillingLogEntry::TEST_BOPS
                "TEST BOPS"
            when DrillingLogEntry::SURFACE_TEST_MWD
                "SURFACE TEST MWD"


            when DrillingLogEntry::STANDBY_OUTHOLE
                "STANDBY"
            when DrillingLogEntry::RIG_SERVICE_OUTHOLE
                "RIG SERVICE OUTHOLE"

        end
    end

end
