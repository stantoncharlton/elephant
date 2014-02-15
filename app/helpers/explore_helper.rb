module ExploreHelper

    def get_county_rops time_range
        months = []
        result = DrillingLog.joins(job: {well: { field: :state }}).where("drilling_logs.updated_at >= ?", Date.today - 1.year).where("fields.county != ''").select("distinct on(county_name) concat(fields.county, ', ', states.name) as county_name, avg(coalesce(drilling_logs.drilling_rop, 0)) AS rop, drilling_logs.updated_at as date, sum(drilling_logs.npt) as npt, sum(drilling_logs.total_time) as total_time, sum(coalesce(jobs.failures_count, 0)) as failures").group("county_name, date")

        result.each do |group|
            months << {
                county: group[:county_name],
                rop: group[:rop].round(1),
                npt: (group[:npt].to_f / group[:total_time].to_f * 100).round(1)
            }
        end
        months
    end

end
