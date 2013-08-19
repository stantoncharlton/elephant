module ActivityExportHelper

    require 'axlsx'

    def to_excel activities, job
        p = Axlsx::Package.new
        wb = p.workbook

        wb.add_worksheet(:name => "Job - " + job.id.to_s) do |sheet|
            sheet.add_row ['User', 'Action', 'Data', 'Date']

            activities.each do |activity|
                if activity.target.instance_of?(JobNote)
                    sheet.add_row [activity.user_name, activity.message, activity.target.text, activity.created_at.strftime("%a %m/%d/%Y %l:%M %p")]
                else
                    sheet.add_row [activity.user_name, activity.message, activity.metadata, activity.created_at.strftime("%a %m/%d/%Y %l:%M %p")]
                end
            end
        end

        p
    end
end