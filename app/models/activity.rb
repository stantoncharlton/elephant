class Activity < ActiveRecord::Base
    attr_accessible :activity_type,
                    :target,
                    :metadata

    belongs_to :company
    belongs_to :user
    belongs_to :job
    belongs_to :target, :polymorphic => true

    #default_scope :order => 'activities.created_at DESC', :limit => 10


    USER_CREATED = 1
    USER_UPDATED = 2
    USER_DESTROYED = 3
    CLIENT_CREATED = 4
    CLIENT_UPDATED = 5
    CLIENT_DESTROYED = 6
    PRODUCT_LINE_CREATED = 7
    PRODUCT_LINE_UPDATED = 8
    PRODUCT_LINE_DESTROYED = 9
    JOB_TEMPLATE_CREATED = 10
    JOB_TEMPLATE_UPDATED = 11
    JOB_TEMPLATE_DESTROYED = 12
    DOCUMENT_CREATED = 13
    DOCUMENT_DESTROYED = 14
    DYNAMIC_FIELD_CREATED = 15
    DYNAMIC_FIELD_DESTROYED = 16
    DISTRICT_CREATED = 17
    DISTRICT_UPDATED = 18
    DISTRICT_DESTROYED = 19


    JOB_CREATED = 100

    DOCUMENT_UPLOADED = 110

    JOB_MEMBER_ADDED = 120

    JOB_NOTE_ADDED = 130


    def message
        case self.activity_type
            when  USER_CREATED
                "New User"
            when USER_UPDATED
                "User updated"
            when USER_DESTROYED
                "User deleted"
            when CLIENT_CREATED
                "New Customer"
            when CLIENT_UPDATED
                "Customer updated"
            when CLIENT_DESTROYED
                "Customer deleted"
            when PRODUCT_LINE_CREATED
                "New Product Line"
            when PRODUCT_LINE_UPDATED
                "Product Line updated"
            when PRODUCT_LINE_DESTROYED
                "Product Line deleted"
            when JOB_TEMPLATE_CREATED
                "New Job Type"
            when JOB_TEMPLATE_UPDATED
                "Job Type updated"
            when JOB_TEMPLATE_DESTROYED
                "Job Type deleted"
            when DOCUMENT_CREATED
                "New Document Template"
            when DOCUMENT_DESTROYED
                "Document Template updated"
            when DYNAMIC_FIELD_CREATED
                "New Custom Data Field"
            when DYNAMIC_FIELD_DESTROYED
                "Custom Data Field deleted"
            when DISTRICT_CREATED
                "New District"
            when DISTRICT_UPDATED
                "District updated"
            when DISTRICT_DESTROYED
                "District deleted"



        end
    end

    def self.add(user, activity_type, target, metadata = "", job = nil)
        return false if user.nil? or user.company.nil? or activity_type.blank? or target.blank?

        activity = Activity.new(activity_type: activity_type, target: target, metadata: metadata)
        activity.user = user
        activity.company = user.company
        activity.job = job

        activity.save!
    end

    def self.admin_activities_for_company(company)
        where("company_id = :company_id", company_id: company.id)
        .where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 1, end_range: 100)
        .order("created_at DESC")
    end

    def self.activities_for_job(job)
        where("job_id = :job_id", job_id: job.id)
        .where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200)
        .order("created_at DESC")
    end

    def self.activities_for_user(user)
        where("user_id = :user_id", user_id: user.id)
        .where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200)
        .order("created_at DESC")
    end
end
