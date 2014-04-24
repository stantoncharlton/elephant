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

    def self.job_total(job)
        costs = 0.0
        if job.present?
            if job.job_costs.any?
                costs = job.job_costs.map { |jc| jc.price * jc.quantity }.reduce(:+)
            end

            parts = job.part_memberships.where("part_memberships.price IS NOT NULL AND part_memberships.price > 0")
            if parts.any?
                days = job.drilling_log.below_rotary.present? && job.drilling_log.above_rotary.present? ? ((job.drilling_log.above_rotary + job.drilling_log.below_rotary) / 24).ceil : 0
                parts.each do |pm|
                    quantity = 1.0
                    if pm.charge_type == JobCost::DAY
                        quantity = days
                    elsif pm.charge_type == JobCost::HOUR && pm.part.present?
                        quantity = pm.part.below_rotary.ceil
                    end

                    costs += quantity * pm.price
                end
            end
        end
        costs
    end

    def self.charge_type_string(charge_type)
        case charge_type
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
