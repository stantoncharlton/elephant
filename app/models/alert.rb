class Alert < ActiveRecord::Base
    attr_accessible :alert_type,
                    :target

    belongs_to :company
    belongs_to :user
    belongs_to :created_by, class_name: "User"
    belongs_to :job
    belongs_to :target, polymorphic: true


    ADDED_TO_JOB = 1
    TASK_ASSIGNED = 2
    NEW_MESSAGE = 3



    def self.add(user, alert_type, target, created_by, job = nil)
        return false if user.nil? or user.company.nil? or alert_type.blank? or target.blank?

        alert = Alert.new(alert_type: alert_type, target: target)
        alert.user = user
        alert.created_by = created_by
        alert.company = user.company
        alert.job = job

        alert.save!
    end

    def self.seen(alert)
        alert.destroy
    end

end
