class DrillingLogEntry < ActiveRecord::Base
    attr_accessible :comment,
                    :entry_at,
                    :activity_code,
                    :depth,
                    :usage_hours,
                    :user_name

    acts_as_tenant(:company)

    validates :comment, presence: true, length: {minimum: 1, maximum: 500}
    validates :entry_at, presence: true
    validates_presence_of :company_id
    validates_presence_of :drilling_log
    validates_presence_of :bha_id
    validates_presence_of :user_id

    belongs_to :drilling_log
    belongs_to :company
    belongs_to :user

    has_one :bha
end
