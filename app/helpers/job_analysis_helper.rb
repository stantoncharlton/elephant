module JobAnalysisHelper

    def personnel_utilization(jobs)
        return 0 unless jobs.count > 0

        districts_query = jobs.select(:district_id).to_sql
        product_lines_query = jobs.joins(:job_template).select(:product_line_id).to_sql
        all_users = User.where("users.district_id IN (#{districts_query}) OR users.product_line_id IN (#{product_lines_query})")

        all_users_query = all_users.select("users.id").to_sql
        jobs_query = jobs.select("jobs.id").to_sql
        active_users_count = JobMembership.where("job_memberships.job_id IN (#{jobs_query}) AND job_memberships.user_id IN (#{all_users_query})").select("DISTINCT user_id").count()
        all_users_count = all_users.count()

        puts "all users: " + all_users_count.to_s
        puts "active users: " + active_users_count.to_s
        ((active_users_count.to_f / all_users_count.to_f) * 100).round(0)
    end

    def total_personnel(jobs)
        jobs_query = jobs.select("jobs.id").to_sql
        JobMembership.where("job_memberships.job_id IN (#{jobs_query})").group(:user_id).count().count
    end

    def total_districts(jobs)
        jobs.reorder('').group(:district_id).count().count
    end

    def total_job_types(jobs)
        jobs.reorder('').group(:job_template_id).count().count
    end

    def average_job_duration(jobs)
        return 0 unless jobs.count > 0
        (jobs.where("close_date IS NOT NULL").sum("close_date - start_date").to_f / jobs.where("close_date IS NOT NULL").count().to_f).round(1)
=begin

        total_time = 0
        total_jobs = 0

        puts jobs.count()

        jobs.each do |job|
            if job.close_date.present?
                total_jobs += 1
                total_time += job.duration
            end
        end


        return 0 unless (total_time.to_f > 0) && (total_jobs.to_f > 0)
        (total_time.to_f / total_jobs.to_f).round(1)
=end
    end

    def average_job_performance(jobs)
        jobs.average(:rating).to_f.round(1)
    end

    def job_failure_rate(jobs)
        return 0 unless jobs.count > 0

        failure_count = jobs.reorder('').joins(:failures).count("failures.id")
        puts "Failure count: " + failure_count.to_s

        ((failure_count.to_f / jobs.count().to_f) * 100).round(0)
    end

    def failures(jobs)
        jobs_query = jobs.select("jobs.id").to_sql
        Failure.where("failures.job_id IN (#{jobs_query})").order("COUNT(failure_master_template_id) DESC").select("failures.*, DISTINCT failure_master_template_id").group(:failure_master_template_id).count()
    end

end
