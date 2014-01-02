class Bha < ActiveRecord::Base
    attr_accessible :name,
                    :description,
                    :bit_to_sensor,
                    :bit_to_gamma,
                    :bit_type,
                    :bit_jets,
                    :bit_tfa,
                    :bit_size,
                    :below_rotary,
                    :above_rotary

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :document_id
    validates_presence_of :job
    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false, scope: [:company_id, :document_id]

    belongs_to :company
    belongs_to :document
    belongs_to :job

    has_many :bha_items, :dependent => :destroy, order: "ordering ASC"

    def update_usage
        drilling_log = DrillingLog.includes(job: :well).where("wells.id = ?", job.well_id).first
        entries = drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id = ?", self.id).to_a
        log = DrillingLog.calculate(entries)

        self.below_rotary = log.below_rotary
        self.above_rotary = log.above_rotary
        self.save

        self.bha_items.each do |bha_item|
            part_membership = bha_item.tool
            if part_membership.part_type == PartMembership::INVENTORY && part_membership.part.present?
                part = part_membership.part
                bha_query = Bha.joins(bha_items: { tool: :part }).where("parts.id = ?", part.id).select("sum(coalesce(bhas.below_rotary, 0)) as total_below_rotary, sum(coalesce(bhas.above_rotary, 0)) as total_above_rotary").first
                part.below_rotary = BigDecimal.new(bha_query[:total_below_rotary])
                part.above_rotary = BigDecimal.new(bha_query[:total_above_rotary])
                part.save
            end
        end
    end

end
