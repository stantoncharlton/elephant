class JobNoteComment < ActiveRecord::Base
    attr_accessible :text,
                    :user_name

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :job_note
    validates :text, length: {minimum: 1, maximum: 1000}

    belongs_to :job_note
    belongs_to :job
    belongs_to :company
    belongs_to :user

end
