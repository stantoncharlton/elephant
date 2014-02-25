module InventoryHelper

    require 'axlsx'

    def parts_to_excel parts
        p = Axlsx::Package.new
        wb = p.workbook

        wb.styles do |s|
            title_cell = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 18, :alignment => {:horizontal => :center}
            title_cell2 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 14, :alignment => {:horizontal => :center}
            column_name_cell = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :sz => 14, :b => true, :alignment => {:horizontal => :left}, :border => {:style => :thin, :color => "00", :edges => [:top, :bottom]}

            cell1 = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 13, :alignment => {:horizontal => :left}
            cell2 = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 13, :alignment => {:horizontal => :left}
            cell1_bold = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => true, :sz => 13, :alignment => {:horizontal => :left}
            cell2_bold = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => true, :sz => 13, :alignment => {:horizontal => :left}
            cell1_available = s.add_style :bg_color => "fafdff", :fg_color => "2fad1e", :b => true, :sz => 13, :alignment => {:horizontal => :left}
            cell1_on_job = s.add_style :bg_color => "fafdff", :fg_color => "0058a8", :b => true, :sz => 13, :alignment => {:horizontal => :left}
            cell1_in_redress = s.add_style :bg_color => "fafdff", :fg_color => "c71a1a", :b => true, :sz => 13, :alignment => {:horizontal => :left}
            cell2_available = s.add_style :bg_color => "f3f6fb", :fg_color => "2fad1e", :b => true, :sz => 13, :alignment => {:horizontal => :left}
            cell2_on_job = s.add_style :bg_color => "f3f6fb", :fg_color => "0058a8", :b => true, :sz => 13, :alignment => {:horizontal => :left}
            cell2_in_redress = s.add_style :bg_color => "f3f6fb", :fg_color => "c71a1a", :b => true, :sz => 13, :alignment => {:horizontal => :left}


            margins = {:left => 1, :right => 1, :top => 1, :bottom => 1, :header => 0, :footer => 0}
            setup = {:fit_to_width => 1, :orientation => :portrait, :paper_width => "21cm", :paper_height => "29.7cm"}
            options = {:grid_lines => true, :headings => true, :horizontal_centered => true}

            wb.add_worksheet(:name => "Inventory", :page_margins => margins, :page_setup => setup, :print_options => options) do |sheet|
                sheet.add_row ['Inventory List', '', '', '', ''], :style => title_cell
                sheet.add_row ['', '', '', '', ''], :style => title_cell
                sheet.add_row ['', '', '', '', ''], :style => title_cell


                sheet.add_row ['Name', 'Material #', 'Serial #', 'Status', ''], :style => column_name_cell

                @parts.each_with_index do |p, index|
                    status = p.status_string
                    cell_status = cell1
                    if p.status == Part::AVAILABLE
                        cell_status = index % 2 == 0 ? cell1_available : cell2_available
                    elsif p.status == Part::ON_JOB
                        cell_status = index % 2 == 0 ? cell1_on_job : cell2_on_job
                        if p.current_job.present?
                            status = p.status_string + ' - ' + (p.current_job.well.rig.present? ? p.current_job.well.rig.name + ' - ' : '') + p.current_job.field.name + ' | ' + p.current_job.well.name
                        end
                    elsif p.status == Part::IN_REDRESS
                        cell_status = index % 2 == 0 ? cell1_in_redress : cell2_in_redress
                    end

                    sheet.add_row [p.master_part.present? ? p.master_part.name : p.name, p.material_number, p.serial_number, status.gsub("<br>", ""), ''], :style => index % 2 == 0 ? [cell1_bold, cell1, cell1, cell_status, cell1] : [cell2_bold, cell2, cell2, cell_status, cell2], :types => [:string, :string, :string, :string, :string]
                end

                sheet.column_widths 20, 15, 20, 66, 0

                sheet.merge_cells("A1:E1")
                sheet.merge_cells("A2:E2")

            end
        end

        p
    end
end