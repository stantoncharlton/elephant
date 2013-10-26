class DrillingLog < ActiveRecord::Base
    attr_accessible :below_rotary,
                    :circulation_hours,
                    :ream_hours,
                    :rop,
                    :rotary_footage_pct,
                    :rotary_hours_pct,
                    :rotate_footage,
                    :rotate_hours,
                    :rotate_rop,
                    :slide_footage_pct,
                    :slide_footgae,
                    :slide_hours,
                    :slide_hours_pct,
                    :slide_rop,
                    :total_drilled

    acts_as_tenant(:company)

    validates_presence_of :company_id
    validates_presence_of :job_id
    validates_presence_of :document_id

    belongs_to :company
    belongs_to :job
    belongs_to :document

    has_many :drilling_log_entries, order: "drilling_log_entries.depth ASC"

    def recalculate
        entries = self.drilling_log_entries.to_a

        below = 0.0

        if entries.any?

            last_time = entries.first.created_at
            below = 0.0

            entries.each do |entry|
                if entry.activity_code >= 1 && entry.activity_code < 50
                    below += ((entry.created_at - last_time) / 24 / 60).to_f
                end

                last_time = entry.created_at
            end

            self.below_rotary = below
            self.total_drilled = entries.last.depth
            self.rop = self.total_drilled.to_f / ((entries.last.created_at - entries.first.created_at)  / 24).to_f

            self.save
        end
    end

end
