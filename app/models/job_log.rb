class JobLog < ActiveRecord::Base
    attr_accessible :comment,
                    :entry_at

    validates :comment, presence: true, length: {maximum: 500}
    validates :entry_at, presence: true
    validates_presence_of :company
    validates_presence_of :job
    validates_presence_of :document
    validates_presence_of :user

    belongs_to :document
    belongs_to :job
    belongs_to :company
    belongs_to :user

end
