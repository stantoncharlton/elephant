class JobProcessController < ApplicationController
    before_filter :signed_in_user, only: [:show, :update]

    def show

        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        if !@job.job_data_good || @job.job_processes.select { |jp| jp.event_type == 1 }.any?
             render :nothing => true, :status => :ok
        end

        @supervisor = @job.supervisor
        @creator = @job.creator

        if !@job.sent_pre_job_ready_email

            mail_to = nil

            if !@supervisor.nil?
                mail_to = @supervisor
            end

            if @supervisor.nil? && !@creator.nil?
                mail_to = @creator
            end

            if !mail_to.nil?
                # Send email
                mail_to.delay.send_pre_job_ready_email(@job)

                @job.sent_pre_job_ready_email = true
                @job.save

                Alert.add(mail_to, Alert::PRE_JOB_DATA_READY, @job, current_user, @job)
            end
        end

    end

    def update

        puts "...................update"

        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        if !@job.job_data_good
            render :nothing => true, :status => :ok
        end

        @supervisor = @job.supervisor
        @creator = @job.creator

        if !current_user?(@supervisor) || !current_user?(@creator)
            render :nothing => true, :status => :ok
        end

        @user = current_user

        @job_process = JobProcess.record(@user, @job, @user.company, JobProcess::APPROVED_TO_SHIP)

        @job.participants.each do |participant|
            participant.delay.send_job_shipping_email(@job)
        end

        render 'job_process/ship'

    end

end
