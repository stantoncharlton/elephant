class JobNoteComment < ActiveRecord::Base
    attr_accessible :text


    belongs_to :job_note
    belongs_to :job
    belongs_to :company
    belongs_to :user

end
