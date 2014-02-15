class DrillingLog < ActiveRecord::Base
    attr_accessible :below_rotary,
                    :above_rotary,
                    :drilling_time,
                    :total_circulation_time,
                    :circulation_hours,
                    :ream_hours,
                    :rop,
                    :drilling_rop,
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
                    :total_drilled,
                    :max_depth,
                    :td_depth,
                    :npt,
                    :total_time

    acts_as_tenant(:company)

    validates_presence_of :company_id
    validates_presence_of :job_id
    validates_presence_of :document_id

    belongs_to :company
    belongs_to :job
    belongs_to :document

    has_many :drilling_log_entries, order: "drilling_log_entries.entry_at ASC"

    attr_accessor :start_depth
    attr_accessor :end_depth

    attr_accessor :ranges

    def recalculate
        drilling_log = DrillingLog.calculate self.drilling_log_entries

        DrillingLog.transaction do
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
            self.max_depth = drilling_log.max_depth
            self.rop = drilling_log.rop
            self.drilling_rop = drilling_log.drilling_rop
            self.drilling_time = drilling_log.drilling_time
            self.total_circulation_time = drilling_log.total_circulation_time
            self.npt = drilling_log.npt
            self.total_time = drilling_log.total_time

            if self.td_depth.blank? || self.td_depth == 0.0
                if self.document.present? && self.document.job.present?
                    active_well_plan = Survey.includes(document: {job: :well}).where("wells.id = ?", self.document.job.well_id).where(:plan => true).order("surveys.updated_at ASC").first
                    if active_well_plan.present? && active_well_plan.survey_points.any?
                        self.td_depth = active_well_plan.survey_points.last.measured_depth
                    end
                end
            end

            self.save

            self.drilling_log_entries.each do |dl|
                if dl.changed?
                    dl.save
                end
            end
        end
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
            drilling_log.max_depth = 0.0
            drilling_log.npt = 0.0
            drilling_log.total_time = 0.0

            drilling_log.ranges = {}

            entries.each do |entry|

                drilling_log.start_depth = drilling_log.start_depth.nil? ? entry.depth : [drilling_log.start_depth, entry.depth].min
                drilling_log.end_depth = drilling_log.end_depth.nil? ? entry.depth : [drilling_log.end_depth, entry.depth].max
                drilling_log.max_depth = drilling_log.max_depth.nil? ? entry.depth : [drilling_log.max_depth, entry.depth].max

                DrillingLogEntry.attribute_names.each do |attribute_name|
                    if attribute_name != "id" && attribute_name != "company_id" && attribute_name != "document_id" && attribute_name != "job_id" && attribute_name != "user_id" && attribute_name != "user_name" && attribute_name != "entry_at" && attribute_name != "created_at" && attribute_name != "updated_at" && attribute_name != "activity_code" && attribute_name != "depth" && attribute_name != "comment" && attribute_name != "bha_id" && attribute_name != "usage_hours" && attribute_name != "drilling_log_id" && attribute_name != "hours" && attribute_name != "rop" && attribute_name != "course_length"

                        if entry[attribute_name].present? && (entry[attribute_name].is_a?(BigDecimal) && entry[attribute_name] != 0.0)
                            if drilling_log.ranges.has_key? (attribute_name + '_min')
                                drilling_log.ranges[attribute_name + '_min'] = [entry[attribute_name], drilling_log.ranges[attribute_name + '_min']].min
                                drilling_log.ranges[attribute_name + '_max'] = [entry[attribute_name], drilling_log.ranges[attribute_name + '_max']].max
                            else
                                drilling_log.ranges[attribute_name + '_min'] = entry[attribute_name]
                                drilling_log.ranges[attribute_name + '_max'] = entry[attribute_name]
                            end
                        end
                    end
                end

                length_change = entry.depth - last_entry.depth
                length_change = [length_change, 0.0].max
                time = [((entry.entry_at - last_time) / 60 / 60).to_f, 0.0].max

                if entry.activity_code != DrillingLogEntry::STANDBY_OUTHOLE
                    if entry.activity_code != DrillingLogEntry::DRILLING &&
                            entry.activity_code != DrillingLogEntry::SLIDING
                        drilling_log.npt += time
                    end
                    drilling_log.total_time += time
                end

                entry.course_length = length_change
                entry.hours = time

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
                elsif entry.activity_code == DrillingLogEntry::TIH_CIRCULATING
                    drilling_log.circulation_hours += time
                elsif entry.activity_code == DrillingLogEntry::CONNECTION_SURVEY
                    #total_drill_time += time
                elsif entry.activity_code == DrillingLogEntry::CONNECTION
                    #total_drill_time += time
                end

                last_time = entry.entry_at
                last_entry = entry

                if length_change > 0 && time > 0
                    entry.rop = length_change / time
                end
            end

            drilling_log.rotary_hours_pct = total_drill_time > 0 ? drilling_log.rotate_hours / total_drill_time : 0.0
            drilling_log.rotary_footage_pct = total_drill_length > 0 ? drilling_log.rotate_footage / total_drill_length : 0.0
            drilling_log.rotate_rop = drilling_log.rotate_hours > 0 ? drilling_log.rotate_footage / drilling_log.rotate_hours : 0.0
            drilling_log.slide_hours_pct = total_drill_time > 0 ? drilling_log.slide_hours / total_drill_time : 0.0
            drilling_log.slide_footage_pct = total_drill_length > 0 ? drilling_log.slide_footage / total_drill_length : 0.0
            drilling_log.slide_rop = drilling_log.slide_hours > 0 ? drilling_log.slide_footage / drilling_log.slide_hours : 0.0

            drilling_log.below_rotary = below
            drilling_log.above_rotary = above
            drilling_log.drilling_time = total_drill_time
            drilling_log.total_circulation_time = total_drill_time + drilling_log.circulation_hours
            drilling_log.total_drilled = total_drill_length
            rop_divisor = below + above
            drilling_log.rop = rop_divisor > 0 ? total_drill_length / rop_divisor : 0.0
            drilling_log.drilling_rop = total_drill_time > 0 ? total_drill_length / total_drill_time : 0.0
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

    def get_surrounding_entries(date, window, entries = self.drilling_log_entries.to_a)
        surrounding_entries = []
        previous = nil
        closest = nil
        past = nil
        run_number = 1
        pooh = false
        last_bha = nil

        if entries.any?
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
                    run_number += 1
                end

                entry.run_number = run_number

                if entry.entry_at >= (date - window) && entry.entry_at <= (date + window)
                    surrounding_entries << entry
                    if entry.entry_at < date
                        previous = entry
                    end
                    # Run after closest
                    if past.nil? && closest.present?
                        past = entry
                        return [surrounding_entries, [previous, closest, past]]
                    end
                    if closest.nil? && entry.entry_at >= date
                        closest = entry
                    end
                end
            end
        end

        [surrounding_entries, [previous, closest, past]]
    end

    def start_on_job_phase
        if self.document.present? && self.document.job.present?
            self.document.job.well.jobs.each do |job|
                if job.status == Job::PRE_JOB
                    if job.documents.where(:document_type => Document::DRILLING_LOG).any?
                        job.begin_on_job
                    end
                end
            end
        end
    end

end
