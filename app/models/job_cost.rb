class JobCost < ActiveRecord::Base
    attr_accessible :charge_at,
                    :charge_type,
                    :description,
                    :price,
                    :quantity


    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :user
    validates_presence_of :job
    validates :description, length: {maximum: 255}
    validates_presence_of :price
    validates_presence_of :quantity
    validates_presence_of :charge_type

    belongs_to :company
    belongs_to :user
    belongs_to :job

    DAY = 1
    JOB = 2
    HOUR = 3
    ITEM = 4

    def charge_type_string
        case self.charge_type
            when DAY
                "Day"
            when JOB
                "Job"
            when HOUR
                "Hour"
            when ITEM
                "Item"
        end
    end

end
