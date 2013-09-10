class SecondaryTool < ActiveRecord::Base
    attr_accessible :serial_number,
                    :received

    acts_as_tenant(:company)

    belongs_to :tool
    belongs_to :job
    belongs_to :company

end
