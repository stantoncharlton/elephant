class PrimaryTool < ActiveRecord::Base

    belongs_to :tool
    belongs_to :job_template

end
