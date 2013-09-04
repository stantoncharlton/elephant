class JobTime < ActiveRecord::Base
    attr_accessible :hours,
                    :status,
                    :time_for

    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :job
    validates_presence_of :status
    validates_presence_of :hours
    validates_presence_of :time_for

    belongs_to :company
    belongs_to :user
    belongs_to :job

    SCHEDULED = 1
    WORKED = 2


    def self.schedule(company, job, user, date, hours)
        return false if company.nil? || job.nil? || user.nil? || date.nil? || hours.nil?

        job_time = JobTime.new
        job_time.job = job
        job_time.company = company
        job_time.time_for = date
        job_time.user = user
        job_time.hours = hours
        job_time.status = JobTime::SCHEDULED

        job_time.save!
        job_time
    end

    def self.worked(company, job, user, date, hours)
        return false if company.nil? || job.nil? || user.nil? || date.nil? || hours.nil?

        job_time = JobTime.where(:company_id => company.id).where(:job_id => job.id).where(:user_id => user.id).where("job_times.time_for >= :start_date AND job_times.time_for <= :end_date", start_date: date.beginning_of_day, end_date: date.end_of_day).first
        if job_time.nil?
            job_time = JobTime.new
            job_time.job = job
            job_time.company = company
            job_time.time_for = date
            job_time.user = user
        end
        job_time.hours = hours
        job_time.status = JobTime::WORKED

        job_time.save!
        job_time
    end

    def self.remove(company, job, user, date)
        return false if company.nil? || job.nil? || user.nil? || date.nil?

        job_time = JobTime.where(:company_id => company.id).where(:job_id => job.id).where(:user_id => user.id).where("job_times.time_for >= :start_date AND job_times.time_for <= :end_date", start_date: date.beginning_of_day, end_date: date.end_of_day).first
        job_time.destroy
        job_time
    end

    def status_string
        case self.status
            when SCHEDULED
                "scheduled"
            when WORKED
                "worked"
        end
    end

end
