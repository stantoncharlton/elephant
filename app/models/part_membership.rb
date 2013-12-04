class PartMembership < ActiveRecord::Base
    attr_accessible :material_number,
                    :name,
                    :serial_number,
                    :part_type,
                    :template,
                    :track_usage,
                    :usage,
                    :optional


    require 'digest/md5'
    acts_as_tenant(:company)

    validates_presence_of :job
    validates_presence_of :part, :if => :part_inventory
    validates_presence_of :name, :if => :part_rental
    validates_presence_of :serial_number, :if => :part_rental

    validates_uniqueness_of :part_id, :scope => :job_id, :if => :part_inventory

    belongs_to :job
    belongs_to :part
    belongs_to :primary_tool
    belongs_to :company


    INVENTORY = 1
    RENTAL = 2
    ACCESSORY = 3

    def part_inventory
        self.part_type == INVENTORY
    end

    def part_rental
        self.part_type == RENTAL
    end

    def part_accessory
        self.part_type == ACCESSORY
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

    def color
        if !self.name.blank?
            Digest::MD5.hexdigest(self.name)[0..5]
        else
            '666666'
        end
    end
end
