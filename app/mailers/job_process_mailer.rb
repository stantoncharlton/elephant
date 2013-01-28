class JobProcessMailer < ActionMailer::Base
    default from: "\"Elephant\" <no-reply@go-elephant.com>"

    def pre_job_data_complete(user, job)
        @user = user
        @job = job
        mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
             :subject => "Pre-Job Complete: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def post_job_data_complete(user, job)
        @user = user
        @job = job
        mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
             :subject => "Post-Job Complete: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def ship_to_field(user, job)
        @user = user
        @job = job
        mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
             :subject => "Job Shipping to Field: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def job_complete(user, job)
        @user = user
        @job = job
        mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
             :subject => "Job Complete: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def added_to_job(user, job)
        @user = user
        @job = job
        mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
             :subject => "Added to Job: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end
end
