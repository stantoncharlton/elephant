class PartMembership < ActiveRecord::Base
    attr_accessible :material_number,
                    :name,
                    :serial_number,
                    :part_type,
                    :template,
                    :track_usage,
                    :shipping,
                    :received,
                    :usage,
                    :optional,
                    :inner_diameter,
                    :outer_diameter,
                    :length,
                    :up,
                    :down,
                    :from_name,
                    :to_name


    require 'digest/md5'
    acts_as_tenant(:company)

    validates_presence_of :company_id
    validates_presence_of :job_id, :if => :not_shipment_present
    validates_presence_of :shipment_id, :if => :shipment_present
    validates_presence_of :part_id, :if => :part_inventory
    validates_presence_of :name, :if => :part_rental
    validates_presence_of :serial_number, :if => :part_rental

    validates_uniqueness_of :part_id, :scope => :job_id, :if => :part_present_and_job

    belongs_to :job
    belongs_to :part
    belongs_to :primary_tool
    belongs_to :supplier
    belongs_to :company
    belongs_to :shipment
    belongs_to :job_part_membership, class_name: "PartMembership"

    belongs_to :from, :polymorphic => true
    belongs_to :to, :polymorphic => true

    belongs_to :bha_item

    INVENTORY = 1
    RENTAL = 2
    ACCESSORY = 3

    def part_present_and_job
        !job_id.blank? && !self.part_id.blank?
    end

    def shipment_present
        !self.shipment_id.blank?
    end

    def not_shipment_present
        self.shipment_id.blank?
    end

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
        part_membership.supplier = self.supplier
        part_membership.company = self.company
        part_membership.material_number = self.material_number
        part_membership.serial_number = self.serial_number
        part_membership.name = self.name
        part_membership.part_type = self.part_type
        part_membership.inner_diameter = inner_diameter
        part_membership.outer_diameter = outer_diameter
        part_membership.length = length
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
