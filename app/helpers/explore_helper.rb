module ExploreHelper

    def get_all_counties_rops time_range
        months = []
        result = DrillingLog.joins(job: {well: {field: :state}}).where("drilling_logs.updated_at >= ?", Date.today - 1.year).where("fields.county != ''").select("distinct on(county_name) concat(fields.county, ', ', states.name) as county_name, avg(coalesce(drilling_logs.drilling_rop, 0)) AS rop, drilling_logs.updated_at as date, sum(drilling_logs.npt) as npt, sum(drilling_logs.total_time) as total_time, sum(coalesce(jobs.failures_count, 0)) as failures, sum(coalesce(drilling_logs.max_depth, 0)) as max_depth, sum(coalesce(jobs.total_cost, 0)) as cost").group("county_name, date")

        result.each do |group|
            months << {
                    county: group[:county_name].gsub("Texas", "TX").gsub("Louisiana", "LA").gsub("Pennsylvania", "PA"),
                    rop: group[:rop].round(1),
                    npt: (group[:npt].to_f / group[:total_time].to_f * 100).round(1),
                    cost: (group[:cost].to_f / group[:max_depth].to_f).round(2),
            }
        end
        months
    end

    def get_county_rops county, time_range
        months = []
        result = DrillingLog.joins(job: {well: {field: :state}}).where("drilling_logs.updated_at >= ?", Date.today - 1.year).where("concat(fields.county, ', ', states.name) = ?", county).select("avg(coalesce(drilling_logs.drilling_rop, 0)) AS rop, avg(coalesce(drilling_logs.rotate_rop, 0)) AS rotate_rop, avg(coalesce(drilling_logs.slide_rop, 0)) AS slide_rop, date_trunc('month', drilling_logs.updated_at) as date, sum(drilling_logs.npt) as npt, sum(drilling_logs.total_time) as total_time, sum(coalesce(jobs.failures_count, 0)) as failures, sum(coalesce(drilling_logs.max_depth, 0)) as max_depth, sum(coalesce(jobs.total_cost, 0)) as cost").group("date")

        12.times do |index|
            months << { month: Date::MONTHNAMES[index + 1] }
        end
        result.each do |group|
            month = Date.strptime(group[:date]).month
            months[month - 1] = {
                    month: Date::MONTHNAMES[month],
                    rop: group[:rop].round(1),
                    rotate_rop: group[:rotate_rop].round(1),
                    slide_rop: group[:slide_rop].round(1),
                    npt: (group[:npt].to_f / group[:total_time].to_f * 100).round(1),
                    cost: (group[:cost].to_f / group[:max_depth].to_f).round(2),
            }
        end
        months
    end


    def get_all_rigs_rops time_range
        rigs = []
        result = DrillingLog.joins(job: {well: :rig}).where("drilling_logs.updated_at >= ?", Date.today - 3.months).select("distinct on(rigs.id) rigs.id, rigs.name as rig_name, avg(coalesce(drilling_logs.drilling_rop, 0)) AS rop, sum(drilling_logs.npt) as npt, sum(drilling_logs.total_time) as total_time, sum(coalesce(drilling_logs.max_depth, 0)) as max_depth, sum(coalesce(jobs.failures_count, 0)) as failures, sum(coalesce(jobs.total_cost, 0)) as cost").group("rigs.id, rigs.name")

        result.each do |group|
            rigs << {
                    rig_name: group[:rig_name],
                    avg_rop: group[:rop].round(1),
                    npt: (group[:npt].to_f / group[:total_time].to_f * 100).round(1),
                    cost: (group[:cost].to_f / group[:max_depth].to_f).round(2)
            }
        end
        rigs
    end

    def get_all_assets_rops time_range, group
        assets = []

        result = DrillingLog.joins(drilling_log_entries: { bha: { bha_items: :tool } }).joins(:job).where("drilling_logs.updated_at >= ?", Date.today - 3.months).select("distinct on(asset_name) part_memberships.name as asset_name, avg(coalesce(drilling_logs.drilling_rop, 0)) AS rop, sum(drilling_logs.npt) as npt, sum(drilling_logs.total_time) as total_time, sum(coalesce(drilling_logs.max_depth, 0)) as max_depth, sum(coalesce(jobs.total_cost, 0)) as cost").group("asset_name")
        if group == 1
            result = result.where("LOWER(part_memberships.name) LIKE '%bit%'")
        elsif group == 2
            result = result.where("LOWER(part_memberships.name) LIKE '%motor%'")
        end

        result.each do |group|
            assets << {
                    asset_name: group[:asset_name],
                    avg_rop: group[:rop].round(1),
                    npt: (group[:npt].to_f / group[:total_time].to_f * 100).round(1),
                    cost: (group[:cost].to_f / group[:max_depth].to_f).round(2),
            }
        end
        assets
    end

end
