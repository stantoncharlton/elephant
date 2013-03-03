task :daily_activity_email => :environment do
    User.all.each do |user|
        if !user.admin?

            activities = Activity.activities_for_user_today(user)
            if !activities.nil? and activities.any?
                UserMailer.daily_activity(user, activities).deliver
            end
        end
    end
end

task :inactive_job_email => :environment do
    Job.all.each do |job|
        if job.status != Job::CLOSED && job.recent_activity(1.month.ago).count == 0

            job_process = @job.job_processes.find { |jp| jp.event_type == JobProcess::LOW_ACTIVITY }

            if job_process.nil?
                creator = job.creator
                supervisor = job.supervisor

                JobProcess.record(creator, job, job.company, JobProcess::LOW_ACTIVITY)

                if !supervisor.nil?
                    JobProcessMailer.job_inactive(supervisor, job).deliver
                end
                if !creator.nil? && supervisor != creator
                    JobProcessMailer.job_inactive(creator, job).deliver
                end
            end
        end
    end
end