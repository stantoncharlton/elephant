class JobProcessMailer < ActionMailer::Base
    default from: "system@go-elephant.com"

    def pre_job_data_complete(user, job)
        @user = user
        @job = job
        mail(:to => "ryan@thirteen23.com, mdawson@dawsonparrish.com, schuldes2004@gmail.com",
             :subject => "Pre-Job complete: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.product_line.name}")
    end

    def ship_to_field(user, job)
        @user = user
        @job = job
        mail(:to => "ryan@thirteen23.com, mdawson@dawsonparrish.com, schuldes2004@gmail.com",
             :subject => "Job Shipping to Field: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.product_line.name}")
    end
end
