class JobNote < ActiveRecord::Base
    attr_accessible :note_type,
                    :text,
                    :user_name

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :note_type
    validates_presence_of :text, :if => :not_activity_report
    validates :text, length: {maximum: 2000}

    belongs_to :company
    belongs_to :user
    belongs_to :assign_to, class_name: "User"
    belongs_to :job
    belongs_to :issue
    belongs_to :owner, :polymorphic => true

    has_many :comments, dependent: :destroy, class_name: "JobNoteComment", order: "created_at asc"

    NOTE = 1
    WARNING = 2
    TASK = 4
    ACTIVITY_REPORT = 5
    ASSET_REQUEST = 6

    def not_activity_report
        self.note_type != ACTIVITY_REPORT
    end


    def create_job_note user

        Activity.add(user, Activity::JOB_NOTE_ADDED, self, nil, self.job)

        if self.assign_to.present?
            alert = Alert.add(self.assign_to, Alert::TASK_ASSIGNED, self, user, self.job)
            self.assign_to.send_alert_email(alert)
        elsif self.note_type == JobNote::WARNING
            self.job.unique_participants.each do |participant|
                alert = Alert.add(participant, Alert::JOB_WARNING, self, user, self.job)
                if user.id != participant.id
                    participant.send_alert_email(alert)
                end
            end
        end
    end

    def parent_collection
        if self.job.present?
            self.job.job_notes
        elsif self.issue.present?
            self.issue.job_notes
        end
    end

    def not_issue_blank
       !self.issue.blank?
    end

    def send_asset_request_alerts user
         if self.job.present?
             self.job.job_memberships.each do |jm|
                 if jm.job_role_id == JobMembership::COORDINATOR || jm.job_role_id == JobMembership::TOOL_COORDINATOR
                     Alert.add(jm.user, Alert::ASSET_REQUEST, self, user, self.job)
                 end
             end
         end
    end

end
