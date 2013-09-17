class PartMembership < ActiveRecord::Base
    attr_accessible :material_number,
                    :template,
                    :track_usage,
                    :usage,
                    :optional

    acts_as_tenant(:company)

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
        if self.primary_tool.present?
            PartMembership.where('part_memberships.material_number = :material_number AND part_memberships.primary_tool_id = :primary_tool_id AND part_memberships.template IS TRUE', material_number: self.material_number, primary_tool_id: primary_tool_id).limit(1).first
        else
            PartMembership.where('part_memberships.material_number = :material_number AND part_memberships.template IS TRUE', material_number: self.material_number).limit(1).first
        end
    end

    def usage_part_membership(job_id)
        if self.primary_tool.present?
            PartMembership.where('part_memberships.material_number = :material_number AND part_memberships.primary_tool_id = :primary_tool_id AND part_memberships.job_id = :job_id AND part_memberships.template IS FALSE', material_number: self.material_number, primary_tool_id: primary_tool_id, job_id: job_id).limit(1).first
        else
            PartMembership.where('part_memberships.material_number = :material_number AND part_memberships.job_id = :job_id AND part_memberships.template IS FALSE', material_number: self.material_number, job_id: job_id).limit(1).first
        end
    end

    def duplicate
        part_membership = PartMembership.new
        part_membership.job = self.job
        part_membership.part = self.part
        part_membership.primary_tool = self.primary_tool
        part_membership.company = self.company
        part_membership.material_number = self.material_number
        part_membership.template = self.template
        part_membership.track_usage = self.track_usage
        part_membership.optional = part_membership
        part_membership
    end

end
