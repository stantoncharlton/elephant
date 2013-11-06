task :daily_activity_email => :environment do
    #User.all.each do |user|
    user = User.find(85)
        if false
            if !user.admin? && user.send_daily_activity

                activities = Activity.activities_for_user_today(user)
                if !activities.nil? and activities.any?
                    UserMailer.daily_activity(user, activities).deliver
                end
            end
        end

        if !user.admin? && user.send_daily_activity

            jobs = user.role.no_assigned_jobs? ? user.company.jobs.reorder('') : user.jobs
            jobs = jobs.includes(dynamic_fields: :dynamic_field_template).includes(:job_memberships, :field, :well, :job_processes, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).where("jobs.status = :status_active OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_active: Job::ACTIVE, status_closed: Job::CLOSED, close_date: (Time.now - 5.days)).
                    order("jobs.created_at DESC")
            if jobs.any?
                UserMailer.daily_activity_report(user, jobs).deliver
            end
        end
    #end
end

task :inactive_job_email => :environment do
    Job.all.each do |job|
        if job.status != Job::CLOSED && job.recent_activity(1.month.ago).count == 0

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

task :assets_not_received_email => :environment do
    Part.all.each do |part|
        if part.status == Part::ON_JOB && part.current_job.present? &&
                part.current_job.status == Job::CLOSED &&
                part.current_job.close_date > 10.days.ago && part.current_job.close_date < 11.days.ago

            job = part.current_job
            creator = job.get_role(JobMembership::CREATOR)
            shop = job.get_role(JobMembership::SHOP)
            coordinator = job.get_role(JobMembership::COORDINATOR)

            if shop.present?
                JobProcessMailer.asset_not_received(shop, job, part).deliver
            end
            if coordinator.present?
                JobProcessMailer.asset_not_received(coordinator, job, part).deliver
            end
            if creator.present? && coordinator.nil? && coordinator != creator
                JobProcessMailer.asset_not_received(creator, job, part).deliver
            end
        end
    end
end