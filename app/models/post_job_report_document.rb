class PostJobReportDocument < ActiveRecord::Base
    attr_accessible :ordering

    validates_uniqueness_of :document_id, scope: :job_template_id

    belongs_to :document
    belongs_to :job_template
    belongs_to :company

end
