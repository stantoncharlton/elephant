class JobLog < ActiveRecord::Base
    attr_accessible :comment

    validates :comment, presence: true
    validates_presence_of :company
    validates_presence_of :job
    validates_presence_of :document
    validates_presence_of :user

    belongs_to :document
    belongs_to :job
    belongs_to :company
    belongs_to :user

end
