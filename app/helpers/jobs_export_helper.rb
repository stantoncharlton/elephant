module JobsExportHelper

    require 'axlsx'

    def to_excel jobs
        p = Axlsx::Package.new
        wb = p.workbook

        wb.add_worksheet(:name => "Job Search") do |sheet|
            #sheet.add_row ['Month', 'Year', 'Type', 'Sales', 'Region']
            #30.times { sheet.add_row [month, year, type, sales, region] }

            columns = Job.new.attributes.map { |j| Job.human_attribute_name(j[0]) }
            sheet.add_row columns

            jobs.each do |job|
                sheet.add_row job.attributes.map { |j| get_expanded_name job, j }
            end
        end

        p
    end

    def get_expanded_name job, entry
         case entry[0]
             when "well_id"
                 return job.well.name
             when "field_id"
                 return job.field.name
             when "job_template_id"
                 return job.job_template.name
             when "district_id"
                 return job.district.present? ? job.district.name : ""
             when "client_id"
                 return job.client.name
             when "company_id"
                 return job.company.name
             when "status"
                 return job.status_string
         end

         entry[1]
    end
end