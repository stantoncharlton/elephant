class JobProcessController < ApplicationController
    before_filter :signed_in_user, only: [:show, :update]

    def show

        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        #@job.flush_cache_status_percentage

        if @job.status == Job::PRE_JOB && !@job.pre_job_data_good
            render :nothing => true, :status => :ok
            return
        elsif (@job.status == Job::ON_JOB || @job.status == Job::POST_JOB) && !@job.post_job_data_good
            render :nothing => true, :status => :ok
            return
        elsif @job.status == Job::COMPLETE
            render :nothing => true, :status => :ok
            return
        end

        @coordinator = @job.get_role(JobMembership::COORDINATOR)
        @creator = @job.get_role(JobMembership::CREATOR)

        participant = @job.job_memberships.find { |p| p.user_id == current_user.id }
        @is_coordinator_or_creator = @job.is_coordinator_or_creator?(current_user)

        mail_to = nil

        if !@coordinator.nil?
            mail_to = @coordinator
        end

        if @coordinator.nil? && !@creator.nil?
            mail_to = @creator
        end

        @sent_post_job_ready_email = @job.sent_post_job_ready_email

        if !mail_to.nil?
            if @job.status == Job::PRE_JOB && !@job.sent_pre_job_ready_email

                mail_to.delay.send_pre_job_ready_email(@job)

                JobProcess.record(current_user, @job, current_user.company, JobProcess::PRE_JOB_DATA_READY)

                Alert.add(mail_to, Alert::PRE_JOB_DATA_READY, @job, current_user, @job)
                Activity.add(current_user, Activity::PRE_JOB_DATA_COMPLETE, @job, nil, @job)

            elsif (@job.status == Job::ON_JOB || @job.status == Job::POST_JOB) && @job.post_job_data_good && !@job.sent_post_job_ready_email

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

        @job.flush_cache_status_percentage

        if !@job.pre_job_data_good
            render :nothing => true, :status => :ok
            return
        end

        @coordinator = @job.get_role(JobMembership::COORDINATOR)
        @creator = @job.get_role(JobMembership::CREATOR)

        participant = @job.job_memberships.find { |p| p.user_id == current_user.id }
        @is_coordinator_or_creator = @job.is_coordinator_or_creator?(current_user)

        @user = current_user

        # Allow anyone to close job
        if @job.sent_post_job_ready_email
            @show_failures = true
            if params[:show_failures] && params[:show_failures] == "false"
                @show_failures = false
            end

            @job_process = nil

            if !@job.approved_to_close
                @job.update_attribute(:status, Job::COMPLETE)
                @job_process = JobProcess.record(@user, @job, @user.company, JobProcess::APPROVED_TO_CLOSE)

                @job.prepare_post_job_report
                @job.delay.close_job current_user
            else
                if @job.post_job_report_document.nil?
                    @job.delay.generate_post_job_report
                end
                @job.update_attribute(:status, Job::COMPLETE)
                @job_process = @job.job_processes.find { |jp| jp.event_type == JobProcess::APPROVED_TO_CLOSE }
            end

            render 'job_process/close'

        elsif @job.sent_pre_job_ready_email && @job.status == Job::PRE_JOB

            if !@is_coordinator_or_creator
                render :nothing => true, :status => :ok
                return
            end

            @job.update_attribute(:status, Job::ON_JOB)
            @job_process = JobProcess.record(@user, @job, @user.company, JobProcess::APPROVED_TO_SHIP)
            @job.delay.ship_job current_user

            render 'job_process/ship'
        end


    end

end
