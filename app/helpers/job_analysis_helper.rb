module JobAnalysisHelper

    def personnel_utilization(jobs)
        return 0 unless jobs.count > 0

        all_users = User.where("users.district_id IN (:districts) OR users.product_line_id IN (:product_lines)", districts: jobs.map { |j| j.district_id }.uniq, product_lines: jobs.map { |j| j.job_template.product_line_id }.uniq)
        active_users = JobMembership.where("job_memberships.job_id IN (:jobs) AND job_memberships.user_id IN (:users)", jobs: jobs.map { |j| j.id }.uniq, users: all_users.map { |j| j.id }.uniq).group(:user_id).count()
        ((active_users.count.to_f / all_users.count().to_f) * 100).round(0)
    end

    def total_personnel(jobs)
        JobMembership.where("job_memberships.job_id IN (?)", jobs.map { |j| j.id }.uniq).group(:user_id).count().count
    end

    def total_districts(jobs)
        jobs.reorder('').group(:district_id).count().count
    end

    def total_job_types(jobs)
        jobs.reorder('').group(:job_template_id).count().count
    end

    def average_job_duration(jobs)
        return 0 unless jobs.count > 0

        jobs.average(:rating).round(1).to_f

        total_time = 0
        total_jobs = 0

        jobs.each do |job|
            if job.close_date.present?
                total_jobs += 1
                total_time += job.duration
            end
        end

        return 0 unless (total_time.to_f > 0) && (total_jobs.to_f > 0)
        (total_time.to_f / total_jobs.to_f).round(1)
    end

    def average_job_performance(jobs)
        jobs.average(:rating).round(1).to_f
    end

    def job_failure_rate(jobs)
        return 0 unless jobs.count > 0

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
        failures.to_a.group_by { |f| f.failure_master_template.id }
    end

end
