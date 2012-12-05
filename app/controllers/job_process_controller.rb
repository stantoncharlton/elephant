class JobProcessController < ApplicationController
    before_filter :signed_in_user, only: [:show, :update]

    def show

        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        if !@job.sent_pre_job_ready_email and !@job.pre_job_data_good
            render :nothing => true, :status => :ok
        elsif !@job.sent_post_job_ready_email and !@job.post_job_data_good
            render :nothing => true, :status => :ok
        elsif @job.approved_to_close
            render :nothing => true, :status => :ok
        end

        @supervisor = @job.supervisor
        @creator = @job.creator

        mail_to = nil

        if !@supervisor.nil?
            mail_to = @supervisor
        end

        if @supervisor.nil? && !@creator.nil?
            mail_to = @creator
        end

        if !mail_to.nil?
            if !@job.sent_pre_job_ready_email

                mail_to.delay.send_pre_job_ready_email(@job)

                JobProcess.record(current_user, @job, current_user.company, JobProcess::PRE_JOB_DATA_READY)

                Alert.add(mail_to, Alert::PRE_JOB_DATA_READY, @job, current_user, @job)

            elsif @job.approved_to_ship and @job.post_job_data_good and !@job.sent_post_job_ready_email

                mail_to.delay.send_post_job_ready_email(@job)

                JobProcess.record(current_user, @job, current_user.company, JobProcess::POST_JOB_DATA_READY)

                Alert.add(mail_to, Alert::POST_JOB_DATA_READY, @job, current_user, @job)

            end
        end

    end

    def update


        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        if !@job.pre_job_data_good
            render :nothing => true, :status => :ok
        end

        @supervisor = @job.supervisor
        @creator = @job.creator

        if !current_user?(@supervisor) || !current_user?(@creator)
            render :nothing => true, :status => :ok
        end

        @user = current_user

        if @job.sent_post_job_ready_email

            @job_process = JobProcess.record(@user, @job, @user.company, JobProcess::APPROVED_TO_CLOSE)

            @job.participants.each do |participant|
                participant.delay.send_job_completed_email(@job)
            end

            render 'job_process/close'

        elsif @job.sent_pre_job_ready_email

            @job_process = JobProcess.record(@user, @job, @user.company, JobProcess::APPROVED_TO_SHIP)

            @job.participants.each do |participant|
                participant.delay.send_job_shipping_email(@job)
            end

            render 'job_process/ship'
        end


    end

end
