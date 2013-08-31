class PartMembership < ActiveRecord::Base
    attr_accessible :material_number,
                    :template

    validates_presence_of :material_number
    validates_presence_of :primary_tool, :if => :template?
    validates_presence_of :job, :if => :not_template
    validates_presence_of :part, :if => :not_template

    belongs_to :job
    belongs_to :part
    belongs_to :primary_tool
    belongs_to :company

    def not_template
        !self.template?
    end

    def template_part_membership
        PartMembership.where('part_memberships.material_number = ? AND part_memberships.template IS TRUE', self.material_number).limit(1).first
    end

    def usage_part_membership(job_id)
        PartMembership.where('part_memberships.material_number = :material_number AND part_memberships.job_id = :job_id AND part_memberships.template IS FALSE', material_number: self.material_number, job_id: job_id).limit(1).first
    end
end
