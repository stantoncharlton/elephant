class DrillingLog < ActiveRecord::Base
    attr_accessible :comment,
                    :entry_at,
                    :activity_code,
                    :depth,
                    :user_name

    acts_as_tenant(:company)

    validates :comment, length: {minimum: 0, maximum: 500}
    validates :entry_at, presence: true
    validates_presence_of :company_id
    validates_presence_of :job_id
    validates_presence_of :document_id
    validates_presence_of :bha_id
    validates_presence_of :user_id

    belongs_to :company
    belongs_to :user
    belongs_to :document
    belongs_to :job
    belongs_to :bha


    START = 1
    CIRCULATING = 2
    DRILLING = 3
    CONNECTION = 4
    SURVEY = 5
    SLIDING = 6


    def activity_code_string
        case self.activity_code
            when START
                "Start"
            when CIRCULATING
                "Circulating"
            when DRILLING
                "Drilling"
            when CONNECTION
                "Connection"
            when SURVEY
                "Survey"
            when SLIDING
                "Sliding"
        end
    end

end
