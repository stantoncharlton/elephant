class SecondaryTool < ActiveRecord::Base

    belongs_to :tool
    belongs_to :job
    belongs_to :company

end
