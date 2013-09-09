class JobProcess < ActiveRecord::Base
    attr_accessible :event_type

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :job

    belongs_to :company
    belongs_to :user
    belongs_to :job


    APPROVED_TO_SHIP = 1
    PRE_JOB_DATA_READY = 2
    POST_JOB_DATA_READY = 3
    APPROVED_TO_CLOSE = 4

    LOW_ACTIVITY = 20

    def self.record(user, job, company, event_type)
        return false if user.nil? or company.nil? or job.nil? or event_type.blank?

        job_process = JobProcess.new(event_type: event_type)
        job_process.user = user
        job_process.company = user.company
        job_process.job = job

        job_process.save!

        job_process
    end


end
