class UserMailer < ActionMailer::Base
    default from: "Elephant <no-reply@go-elephant.com>"

    def registration_confirmation(user, password)
        @user = user
        @password = password
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "#{@user.company.name} Added you to Elephant")
    end

    def reset_password(user, password)
        @user = user
        @password = password
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "Your Elephant New Password")
    end

    def remote_login_password(user, password)
        @user = user
        @password = password
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "Your Elephant Login Code")
    end


    def daily_activity(user, activities)
        @user = user
        @activities = activities
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "Elephant Daily Job Activity")
    end

    def daily_activity_report(user, jobs)
        @user = user
        @jobs = jobs
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "Daily Job Activity Report")
    end

    def alert(user, alert)
        @user = user
        @alert = alert
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "You were assigned a task from " + alert.created_by.name)
    end

    def new_message(user, message)
        @user = user
        @message = message
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "You received a message from " + message.user.name)
    end

    def desktop_app(user)
        @user = user
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "Access Elephant Documents Offline")
    end

    def new_notice_on_job(user, job, document)
        @user = user
        @job = job
        @document = document
        mail(:to => user.company.test_company ? "test-emails@go-elephant.com" : user.email,
             :subject => "New Notice Added on: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

end
