module JobTimesHelper

    def job_times_to_excel start_date
        p = Axlsx::Package.new
        wb = p.workbook

        wb.styles do |s|
            title_cell = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 16, :alignment => {:horizontal => :center}
            title_cell2 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :center}
            title_cell3 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}
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


            wb.add_worksheet(:name => "#{@start_date.strftime("%m-%d")} #{(@start_date + 14.days).strftime("%m-%d")}", :page_margins => margins, :page_setup => setup, :print_options => options) do |sheet|
                sheet.add_row ['Timesheet', '', '', '', ''], :style => title_cell
                sheet.add_row ["#{@start_date.strftime("%m/%d")} - #{(@start_date + 14.days).strftime("%m/%d")}", '', '', '', ''], :style => title_cell2
                sheet.add_row ['', '', '', '', ''], :style => title_cell


                columns = ['Name']
                14.times do |i|
                    columns << (@start_date + (i).days).strftime("%a %d")
                end
                columns << "Total"
                sheet.add_row columns, :style => column_name_cell

                users = User.includes(:job_times).where(:district_id => @district.id).where("users.role_id = 30 OR users.role_id = 31 OR users.role_id = 35 OR users.role_id = 36").order("users.name ASC")
                users.each_with_index do |user, index|

                    cell = index % 2 == 0 ? cell1 : cell2
                    bold = index % 2 == 0 ? cell1_bold : cell2_bold

                    job_times = user.job_times.where("job_times.time_for > :start_date AND job_times.time_for < :end_date", start_date: start_date, end_date: start_date + 14.days).to_a
                    columns = [user.name]
                    total_hours = 0.0
                    14.times do |i|
                        found = job_times.select { |jt| jt.time_for.strftime("%d-%m-%Y") == (start_date + (i).days).strftime("%d-%m-%Y") && jt.status == JobTime::WORKED }
                        if found.any?
                            hours = found.map(&:hours).reduce(:+)
                            columns << ((hours == hours.to_i) ? hours.to_i : hours)
                            total_hours += hours
                        else
                            columns << ''
                        end
                    end

                    columns << total_hours
                    sheet.add_row columns, :style => [bold, cell, cell, cell, cell, cell, cell, cell, cell, cell, cell, cell, cell, cell, cell, bold]
                end

                width = 8
                sheet.column_widths 30, width, width, width, width, width, width, width, width, width, width, width, width, width, width, width

                sheet.merge_cells("A1:P1")
                sheet.merge_cells("A2:P2")
                sheet.merge_cells("A3:P3")

            end
        end

        p
    end
end
