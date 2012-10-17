class Activity < ActiveRecord::Base
    attr_accessible :activity_type,
                    :target

    belongs_to :company
    belongs_to :user
    belongs_to :target, :polymorphic => true

    #default_scope :order => 'activities.created_at DESC', :limit => 10


    USER_CREATED = 1 #target --> model user
    USER_UPDATED = 2 #target --> model user
    USER_DESTROYED = 3 #target --> model user

    def message
        case self.activity_type
            when  USER_CREATED
                "New User"
            when USER_UPDATED
                "User updated"
            when USER_DESTROYED
                "User destroyed"
        end
    end

    def self.add(user, activity_type, target)
        return false if activity_type.blank? or target.blank?

        activity = Activity.new(activity_type: activity_type, target: target)
        activity.user = user
        activity.company = user.company

        activity.save!
    end

    def self.admin_activities_for_company(company)
        where("company_id = :company_id", company_id: company.id)
        .where("activity_type >= :start_range AND activity_type <= :end_range", start_range: USER_CREATED, end_range: USER_DESTROYED)
        .order("created_at DESC")
    end
end
