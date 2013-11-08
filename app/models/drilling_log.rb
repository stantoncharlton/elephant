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
        drilling_log = DrillingLog.calculate self.drilling_log_entries
        self.slide_footage = drilling_log.slide_footage
        self.slide_hours = drilling_log.slide_hours
        self.rotate_footage = drilling_log.rotate_footage
        self.rotate_hours = drilling_log.rotate_hours
        self.ream_hours = drilling_log.ream_hours
        self.circulation_hours = drilling_log.circulation_hours
        self.rotary_hours_pct = drilling_log.rotary_hours_pct
        self.rotary_footage_pct = drilling_log.rotary_footage_pct
        self.rotate_rop = drilling_log.rotate_rop
        self.slide_hours_pct = drilling_log.slide_hours_pct
        self.slide_footage_pct = drilling_log.slide_footage_pct
        self.slide_rop = drilling_log.slide_rop
        self.below_rotary = drilling_log.below_rotary
        self.total_drilled = drilling_log.total_drilled
        self.rop = drilling_log.rop
        self.save
    end

    def self.calculate drilling_log_entries
        drilling_log = DrillingLog.new
        entries = drilling_log_entries.to_a

        if entries.any?
            last_entry = entries.first
            last_time = entries.first.entry_at
            below = 0.0
            time = 0.0
            length_change = 0.0
            total_drill_time = 0.0
            total_drill_length = 0.0
            drilling_log.slide_footage = 0.0
            drilling_log.slide_hours = 0.0
            drilling_log.rotate_footage = 0.0
            drilling_log.rotate_hours = 0.0
            drilling_log.ream_hours = 0.0
            drilling_log.circulation_hours = 0.0

            entries.each do |entry|

                length_change = entry.depth - last_entry.depth
                total_drill_length += length_change

                if entry.activity_code >= 1 && entry.activity_code < 50
                    time = ((entry.entry_at - last_time) / 60 / 60).to_f
                    below += time
                end

                if entry.activity_code == DrillingLogEntry::SLIDE
                    total_drill_time += time
                    drilling_log.slide_footage += length_change
                    drilling_log.slide_hours += time
                elsif entry.activity_code == DrillingLogEntry::ROTATE
                    total_drill_time += time
                    drilling_log.rotate_footage += length_change
                    drilling_log.rotate_hours += time
                elsif entry.activity_code == DrillingLogEntry::REAMING
                    drilling_log.ream_hours += time
                elsif entry.activity_code == DrillingLogEntry::CIRCULATE
                    drilling_log.circulation_hours += time
                end

                last_time = entry.entry_at
                last_entry = entry
            end

            drilling_log.rotary_hours_pct = drilling_log.rotate_hours / total_drill_time
            drilling_log.rotary_footage_pct = drilling_log.rotate_footage / total_drill_length
            drilling_log.rotate_rop = drilling_log.rotate_footage / drilling_log.rotate_hours / 60
            drilling_log.slide_hours_pct = drilling_log.slide_hours / total_drill_time
            drilling_log.slide_footage_pct = drilling_log.slide_footage / total_drill_length
            drilling_log.slide_rop = drilling_log.slide_footage / drilling_log.slide_hours / 60

            drilling_log.below_rotary = below
            drilling_log.total_drilled = total_drill_length
            drilling_log.rop = total_drill_length / ((entries.last.entry_at - entries.first.entry_at)  / 60).to_f
        end

        drilling_log
    end

end
