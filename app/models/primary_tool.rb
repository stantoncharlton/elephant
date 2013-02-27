class PrimaryTool < ActiveRecord::Base

    validates_uniqueness_of :tool_id, scope: :job_template_id

    belongs_to :tool
    belongs_to :job_template

end
