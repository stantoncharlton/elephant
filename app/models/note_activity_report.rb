class NoteActivityReport < ActiveRecord::Base
    attr_accessible :future,
                    :past,
                    :present

    acts_as_tenant(:company)

    validates_presence_of :company
    validates :future, length: {maximum: 255}
    validates :past, length: {maximum: 255}
    validates :present, length: {maximum: 255}

    belongs_to :company
    belongs_to :job
    belongs_to :job_note

end
