class SecondaryTool < ActiveRecord::Base

    acts_as_tenant(:company)

    belongs_to :tool
    belongs_to :job
    belongs_to :company

end
