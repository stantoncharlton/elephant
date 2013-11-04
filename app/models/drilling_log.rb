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
                    :slide_footage,
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

            last_entry = entries.first
            last_time = entries.first.entry_at
            below = 0.0
            time = 0.0
            length_change = 0.0
            total_drill_time = 0.0
            total_drill_length = 0.0

            self.slide_footage = 0.0
            self.slide_hours = 0.0
            self.rotate_footage = 0.0
            self.rotate_hours = 0.0

            self.ream_hours = 0.0
            self.circulation_hours = 0.0

            entries.each do |entry|

                length_change = entry.depth - last_entry.depth
                total_drill_length += length_change

                if entry.activity_code >= 1 && entry.activity_code < 50
                    time = ((entry.entry_at - last_time) / 60 / 60).to_f
                    below += time
                end

                if entry.activity_code == DrillingLogEntry::SLIDE
                    total_drill_time += time
                    self.slide_footage += length_change
                    self.slide_hours += time
                elsif entry.activity_code == DrillingLogEntry::ROTATE
                    total_drill_time += time
                    self.rotate_footage += length_change
                    self.rotate_hours += time
                elsif entry.activity_code == DrillingLogEntry::REAMING
                    self.ream_hours += time
                elsif entry.activity_code == DrillingLogEntry::CIRCULATE
                    self.circulation_hours += time
                end

                last_time = entry.entry_at
                last_entry = entry
            end

            self.rotary_hours_pct = self.rotate_hours / total_drill_time
            self.rotary_footage_pct = self.rotate_footage / total_drill_length
            self.rotate_rop = self.rotate_footage / self.rotate_hours / 60
            self.slide_hours_pct = self.slide_hours / total_drill_time
            self.slide_footage_pct = self.slide_footage / total_drill_length
            self.slide_rop = self.slide_footage / self.slide_hours / 60

            self.below_rotary = below
            self.total_drilled = total_drill_length
            self.rop = total_drill_length / ((entries.last.entry_at - entries.first.entry_at)  / 60).to_f

            self.save
        end
    end

end
