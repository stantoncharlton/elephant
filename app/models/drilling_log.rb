class DrillingLog < ActiveRecord::Base

    acts_as_tenant(:company)

    validates_presence_of :company_id
    validates_presence_of :job_id
    validates_presence_of :document_id

    belongs_to :document
    belongs_to :job
    belongs_to :company

    has_many :drilling_log_entries

end
