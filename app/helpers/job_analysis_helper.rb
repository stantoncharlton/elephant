module JobAnalysisHelper

    def personnel_utilization(jobs)
        all_users = User.where("users.district_id IN (?)", jobs.map { |j| j.district_id }.uniq).
                where("users.product_line_id IN (?)", jobs.map { |j| j.job_template.product_line_id }.uniq).count(group: :id)
        active_users = JobMembership.where("job_memberships.job_id IN (?)", jobs.map { |j| j.id }.uniq).count(group: :user_id)

        puts "active users: " + active_users.count.to_s
        puts "all users: " + all_users.count.to_s
        ((active_users.count.to_f / all_users.count.to_f) * 100).round(0)
    end

    def average_job_duration(jobs)
        total_time = 0
        total_jobs = 0

        jobs.each do |job|
            if job.close_date.present?
                total_jobs += 1
                total_time += job.duration
            end
        end

        (total_time.to_f / total_jobs.to_f).round(1)
    end

    def job_failure_rate(jobs)
        total_failures = 0
        total_jobs = 0

        jobs.each do |job|
            total_jobs += 1
            total_failures += (job.failures.count > 0) ? 1 : 0
        end

        ((total_failures.to_f / total_jobs.to_f) * 100).round(0)
    end

    def failures(jobs)
        failures = Failure.where("failures.job_id IN (?)", jobs.map { |j| j.id }.uniq)
        failures.to_a.group_by {|f| f.failure_master_template.id }
    end

end
