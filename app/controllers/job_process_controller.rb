class JobProcessController < ApplicationController
    before_filter :signed_in_user, only: [:show, :update]

    def show

        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        if !@job.pre_job_data_good
            render :nothing => true, :status => :ok
            return
        elsif @job.approved_to_ship and !@job.sent_post_job_ready_email and !@job.post_job_data_good

            render :nothing => true, :status => :ok
            return
        elsif @job.approved_to_close

            render :nothing => true, :status => :ok
            return
        end

        @supervisor = @job.supervisor
        @creator = @job.creator

        participant = @job.job_memberships.find { |p| p.user_id == current_user.id }
        @is_supervisor_or_creator = participant.job_role_id == JobMembership::CREATOR || participant.job_role_id == JobMembership::SUPERVISOR

        mail_to = nil

        if !@supervisor.nil?
            mail_to = @supervisor
        end

        if @supervisor.nil? && !@creator.nil?
            mail_to = @creator
        end

        @sent_post_job_ready_email = @job.sent_post_job_ready_email

        if !mail_to.nil?
            if !@job.sent_pre_job_ready_email

                mail_to.delay.send_pre_job_ready_email(@job)

                JobProcess.record(current_user, @job, current_user.company, JobProcess::PRE_JOB_DATA_READY)

                Alert.add(mail_to, Alert::PRE_JOB_DATA_READY, @job, current_user, @job)
                Activity.add(current_user, Activity::PRE_JOB_DATA_COMPLETE, @job, nil, @job)

            elsif @job.approved_to_ship and @job.post_job_data_good and !@job.sent_post_job_ready_email

                @sent_post_job_ready_email = true

                mail_to.delay.send_post_job_ready_email(@job)

                JobProcess.record(current_user, @job, current_user.company, JobProcess::POST_JOB_DATA_READY)

                Alert.add(mail_to, Alert::POST_JOB_DATA_READY, @job, current_user, @job)
                Activity.add(current_user, Activity::POST_JOB_DATA_COMPLETE, @job, nil, @job)

            end
        end

    end

    def update


        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        if !@job.pre_job_data_good
            render :nothing => true, :status => :ok
            return
        end

        @supervisor = @job.supervisor
        @creator = @job.creator

        participant = @job.job_memberships.find { |p| p.user_id == current_user.id }
        @is_supervisor_or_creator = participant.job_role_id == JobMembership::CREATOR || participant.job_role_id == JobMembership::SUPERVISOR

        if !@is_supervisor_or_creator
            render :nothing => true, :status => :ok
            return
        end

        @user = current_user

        if @job.sent_post_job_ready_email
            @show_failures = true
            if params[:show_failures] && params[:show_failures] == "false"
                @show_failures = false
            end

            if !@job.approved_to_close
                @job_process = JobProcess.record(@user, @job, @user.company, JobProcess::APPROVED_TO_CLOSE)

                @job.prepare_post_job_report
                @job.delay.close_job current_user
            else
                if @job.post_job_report_document.nil?
                    @job.delay.generate_post_job_report
                end
                @job_process = @job.job_processes.find { |jp| jp.event_type == JobProcess::APPROVED_TO_CLOSE }
            end

            render 'job_process/close'

        elsif @job.sent_pre_job_ready_email

            @job_process = JobProcess.record(@user, @job, @user.company, JobProcess::APPROVED_TO_SHIP)
            @job.delay.ship_job current_user

            render 'job_process/ship'
        end


    end

end
