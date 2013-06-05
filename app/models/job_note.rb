class JobNote < ActiveRecord::Base
    attr_accessible :note_type,
                    :text,
                    :user_name

    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :job
    validates_presence_of :note_type
    validates_presence_of :text


    belongs_to :company
    belongs_to :user
    belongs_to :assign_to, class_name: "User"
    belongs_to :job


    has_many :comments, dependent: :destroy, class_name: "JobNoteComment", order: "created_at asc"

    NOTE = 1
    WARNING = 2
    TASK = 4


    def create_job_note user

        Activity.add(user, Activity::JOB_NOTE_ADDED, self, nil, self.job)

        if self.assign_to.present?
            alert = Alert.add(self.assign_to, Alert::TASK_ASSIGNED, self, user, self.job)
            self.assign_to.send_alert_email(alert)
        elsif self.note_type == JobNote::WARNING
            self.job.unique_participants.each do |participant|
                alert = Alert.add(participant, Alert::TASK_ASSIGNED, self, user, self.job)
                participant.send_alert_email(alert)
            end
        end
    end

end
