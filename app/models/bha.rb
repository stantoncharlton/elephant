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
                    :above_rotary,
                    :total_circulation

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :job
    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false, scope: [:company_id, :job_id]

    belongs_to :company
    belongs_to :job
    belongs_to :drilling_log_entry

    has_many :bha_items, :dependent => :destroy, order: "ordering ASC"

    belongs_to :master_bha, class_name: "Bha"
    has_one :tool_string, :dependent => :destroy, class_name: "Bha", foreign_key: "master_bha_id"

    def update_usage
        return unless self.job.present?

        drilling_log = DrillingLog.includes(job: :well).where("wells.id = ?", self.job.well_id).first
        entries = drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id = ?", self.master_bha.present? ? self.master_bha_id : self.id).to_a
        log = DrillingLog.calculate(entries)

        self.below_rotary = log.below_rotary
        self.above_rotary = log.above_rotary
        self.total_circulation = log.total_circulation_time
        self.save

        self.bha_items.each do |bha_item|
            part_membership = bha_item.tool
            if part_membership.present? && part_membership.part.present?
                part = part_membership.part
                bha_query = Bha.joins(bha_items: {tool: :part}).where("parts.id = ?", part.id).select("sum(coalesce(bhas.below_rotary, 0)) as total_below_rotary, sum(coalesce(bhas.above_rotary, 0)) as total_above_rotary, sum(coalesce(bhas.total_circulation, 0)) as total_circulation").first
                part.below_rotary = BigDecimal.new(bha_query[:total_below_rotary])
                part.above_rotary = BigDecimal.new(bha_query[:total_above_rotary])
                part.total_circulation = BigDecimal.new(bha_query[:total_circulation])
                part.save
            end
        end

        if !self.tool_string.nil?
            self.tool_string.update_usage
        end

        self.job.delay.update_cost
    end

    def create_activity user, activity
        if self.job.unique_participants.where("users.id = ?", user.id).present?
            Activity.add(user, activity, self, "#{self.name} - #{self.description}", self.job)
        end
    end

end
