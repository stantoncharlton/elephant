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

end
