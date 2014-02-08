task :daily_activity_email => :environment do
    Time.zone = "Central Time (US & Canada)"
    User.all.each do |user|
        #user = User.find(85)

        if !user.admin? && user.send_daily_activity

            jobs = !user.role.limit_to_assigned_jobs? ? user.company.jobs.reorder('') : user.jobs
            #jobs = user.role.no_assigned_jobs? ? user.company.jobs.reorder('') : user.jobs
            jobs = jobs.includes(dynamic_fields: :dynamic_field_template).includes(:job_memberships, :field, :well, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_closed: Job::COMPLETE, close_date: (Time.now - 5.days)).
                    order("jobs.created_at DESC")
            if jobs.any?
                begin
                    UserMailer.daily_activity_report(user, jobs).deliver
                rescue
                    UserMailer.daily_activity_report(user, jobs).deliver
                end
            end
        end
    end
end

task :inactive_job_email => :environment do
    Job.all.each do |job|
        if job.status != Job::COMPLETE && job.recent_activity(1.month.ago).count == 0

            job_process = job.job_processes.find { |jp| jp.event_type == JobProcess::LOW_ACTIVITY }

            if job_process.nil? || job_process.created_at.day == Date.today.day
                creator = job.get_role(JobMembership::CREATOR)
                coordinator = job.get_role(JobMembership::COORDINATOR)

                JobProcess.record(creator || coordinator, job, job.company, JobProcess::LOW_ACTIVITY)

                if !coordinator.nil?
                    JobProcessMailer.job_inactive(coordinator, job).deliver
                end
                if !creator.nil? && coordinator != creator
                    JobProcessMailer.job_inactive(creator, job).deliver
                end
            end
        end
    end
end
