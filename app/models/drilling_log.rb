class DrillingLog < ActiveRecord::Base
    attr_accessible :below_rotary,
                    :above_rotary,
                    :drilling_time,
                    :total_circulation_time,
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

    has_many :drilling_log_entries, order: "drilling_log_entries.depth ASC, drilling_log_entries.entry_at ASC"

    attr_accessor :start_depth
    attr_accessor :end_depth
    attr_accessor :low_wob
    attr_accessor :high_wob
    attr_accessor :low_flow
    attr_accessor :high_flow

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
        self.above_rotary = drilling_log.above_rotary
        self.below_rotary = drilling_log.below_rotary
        self.total_drilled = drilling_log.total_drilled
        self.rop = drilling_log.rop
        self.drilling_time = drilling_log.drilling_time
        self.total_circulation_time = drilling_log.total_circulation_time
        self.save
    end

    def self.calculate drilling_log_entries
        drilling_log = DrillingLog.new
        entries = drilling_log_entries.to_a

        if entries.any?
            last_entry = entries.first
            last_time = entries.first.entry_at
            below = 0.0
            above = 0.0
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

                drilling_log.start_depth = drilling_log.start_depth.nil? ? entry.depth : [drilling_log.start_depth, entry.depth].min
                drilling_log.end_depth = drilling_log.end_depth.nil? ? entry.depth : [drilling_log.end_depth, entry.depth].max
                if entry.wob.present?
                    drilling_log.low_wob = drilling_log.low_wob.nil? ? entry.wob : [drilling_log.low_wob, entry.wob].min
                    drilling_log.high_wob = drilling_log.high_wob.nil? ? entry.wob : [drilling_log.high_wob, entry.wob].max
                end
                if entry.flow.present?
                    drilling_log.low_flow = drilling_log.low_flow.nil? ? entry.flow : [drilling_log.low_flow, entry.flow].min
                    drilling_log.high_flow = drilling_log.high_flow.nil? ? entry.flow : [drilling_log.high_flow, entry.flow].max
                end

                length_change = entry.depth - last_entry.depth

                time = ((entry.entry_at - last_time) / 60 / 60).to_f

                if entry.activity_code >= 1 && entry.activity_code < 100
                    below += time
                else
                    above += time
                end

                if entry.activity_code == DrillingLogEntry::SLIDING || entry.activity_code == DrillingLogEntry::DRILLING
                    total_drill_length += length_change
                end

                if entry.activity_code == DrillingLogEntry::SLIDING
                    total_drill_time += time
                    drilling_log.slide_footage += length_change
                    drilling_log.slide_hours += time
                elsif entry.activity_code == DrillingLogEntry::DRILLING
                    total_drill_time += time
                    drilling_log.rotate_footage += length_change
                    drilling_log.rotate_hours += time
                elsif entry.activity_code == DrillingLogEntry::REAMING
                    drilling_log.ream_hours += time
                elsif entry.activity_code == DrillingLogEntry::CIRCULATING
                    drilling_log.circulation_hours += time
                end

                last_time = entry.entry_at
                last_entry = entry
            end

            drilling_log.rotary_hours_pct = total_drill_time > 0 ? drilling_log.rotate_hours / total_drill_time : 0.0
            drilling_log.rotary_footage_pct = total_drill_length > 0 ? drilling_log.rotate_footage / total_drill_length : 0.0
            drilling_log.rotate_rop = drilling_log.rotate_hours > 0 ? drilling_log.rotate_footage / drilling_log.rotate_hours / 60 : 0.0
            drilling_log.slide_hours_pct = total_drill_time > 0 ? drilling_log.slide_hours / total_drill_time : 0.0
            drilling_log.slide_footage_pct = total_drill_length > 0 ? drilling_log.slide_footage / total_drill_length : 0.0
            drilling_log.slide_rop = drilling_log.slide_hours > 0 ? drilling_log.slide_footage / drilling_log.slide_hours / 60 : 0.0

            drilling_log.below_rotary = below
            drilling_log.above_rotary = above
            drilling_log.drilling_time = total_drill_time
            drilling_log.total_circulation_time = total_drill_time + drilling_log.circulation_hours
            drilling_log.total_drilled = total_drill_length
            rop_divisor = ((entries.last.entry_at - entries.first.entry_at) / 60).to_f
            drilling_log.rop = rop_divisor > 0 ? total_drill_length / rop_divisor : 0.0
        end

        drilling_log.drilling_log_entries = entries
        drilling_log
    end

    def get_times(entries = self.drilling_log_entries.to_a)
        hash = {}

        if entries.any?
            last_entry = entries.first
            entries.each do |entry|
                time = ((entry.entry_at - last_entry.entry_at) / 60 / 60).to_f
                if hash.has_key?(entry.activity_code)
                    sub_hash = hash[entry.activity_code]
                    sub_hash[:time] += time
                    sub_hash[:entries] += 1
                else
                    hash.merge!(entry.activity_code => {time: time, activity_code: entry.activity_code, activity_code_string: DrillingLogEntry.activity_code_string(entry.activity_code), entries: 1})
                end

                last_entry = entry
            end
        end

        hash
    end

    def get_runs(entries = self.drilling_log_entries.to_a)
        runs = []

        if entries.any?
            current_run = []
            pooh = false
            last_bha = nil

            entries.each do |entry|
                if entry.activity_code == DrillingLogEntry::POOH
                    pooh = true
                    last_bha = entry.bha
                end

                if pooh &&
                        (entry.bha != last_bha ||
                                entry.activity_code == DrillingLogEntry::CHANGE_BHA ||
                                entry.activity_code == DrillingLogEntry::TIH)
                    pooh = false
                    runs << current_run
                    current_run = []
                end

                if entry.activity_code >= 1 && entry.activity_code < 100
                    current_run << entry
                end

            end

            if current_run.any?
                runs << current_run
            end
        end

        runs
    end

end
