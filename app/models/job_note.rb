class JobNote < ActiveRecord::Base
    attr_accessible :note_type,
                    :text

    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :job
    validates_presence_of :note_type
    validates_presence_of :text


    belongs_to :company
    belongs_to :user
    belongs_to :assign_to, class_name: "User"
    belongs_to :job


    has_many :comments, class_name: "JobNoteComment", order: "created_at asc"


end
