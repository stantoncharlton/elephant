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
            months << {month: Date::MONTHNAMES[index + 1]}
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
        result = DrillingLog.joins(job: {well: :rig}).where("drilling_logs.updated_at >= ?", Date.today - 1.year).select("distinct on(rigs.id) rigs.id, rigs.name as rig_name, avg(coalesce(drilling_logs.drilling_rop, 0)) AS rop, sum(drilling_logs.npt) as npt, sum(drilling_logs.total_time) as total_time, sum(coalesce(drilling_logs.max_depth, 0)) as max_depth, sum(coalesce(jobs.failures_count, 0)) as failures, sum(coalesce(jobs.total_cost, 0)) as cost").group("rigs.id, rigs.name")

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

        result = DrillingLog.joins(drilling_log_entries: {bha: {bha_items: :tool}}).joins(:job).where("drilling_logs.updated_at >= ?", Date.today - 1.year).select("distinct on(asset_name) part_memberships.name as asset_name, avg(coalesce(drilling_logs.drilling_rop, 0)) AS rop, sum(drilling_logs.npt) as npt, sum(drilling_logs.total_time) as total_time, sum(coalesce(drilling_logs.max_depth, 0)) as max_depth, sum(coalesce(jobs.total_cost, 0)) as cost").group("asset_name")
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

    def get_well_costs
        costs = []

        result = DrillingLog.joins(job: {well: { field: :state }}).select("wells.name, concat(fields.county, ', ', states.name) as county_name, coalesce(drilling_logs.max_depth, 0) as max_depth, coalesce(jobs.total_cost, 0) as cost").order("max_depth").where("max_depth > 0")

        result.each do |r|
            costs << { depth: r[:max_depth], cost: r[:cost], county: r[:county_name], color: '#' + Digest::MD5.hexdigest(r[:county_name])[0..5]}
        end

        costs
    end

    def get_trend_line(series, x_attribute, y_attribute)
        x_attribute = x_attribute.to_sym
        y_attribute = y_attribute.to_sym
        n = series.count
        sum = 0
        x = 0
        y = 0
        c_sum = 0
        min_x = series.first[x_attribute]
        max_x = series.first[x_attribute]
        series.each do |c|
            sum += (c[x_attribute] * c[y_attribute].to_f)
            x += c[x_attribute]
            y += c[y_attribute].to_f
            c_sum += c[x_attribute] * c[x_attribute]
            min_x = [c[x_attribute], min_x].min
            max_x = [c[x_attribute], max_x].max
        end
        a = n * sum
        b = x * y
        c = n * c_sum
        d = x * x
        m = (a - b) / (c - d)
        e = y
        f = m * x
        b2 = (e - f) / n

        start_y = (m * min_x) + b2
        end_y = (m * max_x) + b2

        [min_x, start_y, max_x, end_y]
    end


    def get_incidents
        incidents = []

        result = Issue.joins(failure: :failure_master_template).all

        result.each do |r|
            name = r.failure.failure_master_template.text
            incidents << { date: r.failure_at, type: r.failure.failure_master_template_id, name: name, color: '#' + Digest::MD5.hexdigest(name)[0..5], depth: [*2000..16000].sample }
        end

        incidents
    end

    def get_perfect_well_ratios
        pwr = []

        result = DrillingLog.joins(job: {well: { field: :state }}).select("wells.name, jobs.perfect_well_ratio as pwr, concat(fields.county, ', ', states.name) as county_name, coalesce(drilling_logs.max_depth, 0) as max_depth, coalesce(jobs.total_cost, 0) as cost").order("jobs.created_at").where("max_depth > 0")

        sequence = 1
        result.each do |r|
            pwr << { perfect_well_ratio: r[:pwr].to_f.round(2), sequence: sequence, depth: r[:max_depth], cost: r[:cost], county: r[:county_name], color: '#' + Digest::MD5.hexdigest(r[:county_name])[0..5]}
            sequence += 1
        end

        pwr
    end


end
