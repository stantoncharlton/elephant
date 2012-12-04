class JobNoteComment < ActiveRecord::Base
    attr_accessible :text


    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :job
    validates_presence_of :job_note

    belongs_to :job_note
    belongs_to :job
    belongs_to :company
    belongs_to :user

end
