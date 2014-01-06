module DrillingLogsHelper

    include ActionView::Helpers::NumberHelper

    def fill_drilling_report job, entries, r, start_time, end_time
        drilling_log = DrillingLog.calculate entries
        issues = Issue.includes(job: :well).where("wells.id = ?", job.well_id)

        r.add_field "JOB_NAME", job.field.name + ' - ' + job.well.name
        r.add_field "JOB_NUMBER", 'Job # ' + (job.job_number || '-')
        r.add_field "RIG", 'Rig ' + (job.well.rig.present? ? job.well.rig.name : '-')
        r.add_field "CLIENT", job.company.name

        r.add_field "T1", drilling_log.rop.nil? ? "-" : drilling_log.rop.round(1)
        r.add_field "T2", drilling_log.total_drilled.nil? ? "-" : number_with_delimiter(drilling_log.total_drilled.to_i, :delimiter => ',')
        r.add_field "T3", drilling_log.rop.nil? ? "-" : drilling_log.drilling_time.round(1)
        r.add_field "T4", drilling_log.rop.nil? ? "-" : drilling_log.total_circulation_time.round(1)
        r.add_field "T5", issues.count
        r.add_field "T6", "-"
        r.add_field "T7", "-"
        r.add_field "T8", "-"

        r.add_field "C1", "-"
        r.add_field "C2", "-"


        r.add_field "R1", drilling_log.rotary_footage_pct.nil? ? "-" : drilling_log.rotary_footage_pct.round(1)
        r.add_field "R2", drilling_log.rotary_hours_pct.nil? ? "-" : drilling_log.rotary_hours_pct.round(1)
        r.add_field "R3", drilling_log.rotate_rop.nil? ? "-" : drilling_log.rotate_rop.round(1)
        r.add_field "R4", drilling_log.rotate_footage.nil? ? "-" : number_with_delimiter(drilling_log.rotate_footage.to_i, :delimiter => ',')
        r.add_field "R5", drilling_log.rotate_hours.nil? ? "-" : drilling_log.rotate_hours.round(1)
        r.add_field "R6", "-"

        r.add_field "S1", drilling_log.slide_footage_pct.nil? ? "-" : drilling_log.slide_footage_pct.round(1)
        r.add_field "S2", drilling_log.slide_hours_pct.nil? ? "-" : drilling_log.slide_hours_pct.round(1)
        r.add_field "S3", drilling_log.slide_rop.nil? ? "-" : drilling_log.slide_rop.round(1)
        r.add_field "S4", drilling_log.slide_footage.nil? ? "-" : number_with_delimiter(drilling_log.slide_footage.to_i, :delimiter => ',')
        r.add_field "S5", drilling_log.slide_hours.nil? ? "-" : drilling_log.slide_hours.round(1)
        r.add_field "S6", "-"
    end

end
