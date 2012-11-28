class JobProcessMailer < ActionMailer::Base
    default from: "system@go-elephant.com"

    def pre_job_data_complete(user, job)
        @user = user
        @job = job
        mail(:to => "ryan@thirteen23.com", :subject => "Pre-Job complete for #{@job.field.name} | #{@job.well.name} | #{@job.job_template.product_line.name}")
    end
end
