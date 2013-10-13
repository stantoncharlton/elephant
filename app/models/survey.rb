class Survey < ActiveRecord::Base
    attr_accessible :name,
                    :plan

    belongs_to :company
    belongs_to :document
    belongs_to :job
    belongs_to :user

    has_many :survey_points, :dependent => :destroy, :order => "created_at ASC"


    def calculated_points
        survey_points = self.survey_points.to_a

        last_point = nil
        tvd = 0.0
        vs = 0.0
        rc = 1.0
        ns = 0.0
        ew = 0.0
        beta = 0.0
        rf = 1.0

        survey_points.each do |point|
            if point.tie_on
                tvd = point.true_vertical_depth
                ns = point.north_south
                ew = point.east_west
                point.vertical_section = 0.0
            else
                if point.inclination - last_point.inclination != 0 || point.azimuth - last_point.azimuth != 0
                    beta = Math::cos((point.inclination - last_point.inclination)*(Math::PI/180))-(Math::sin(last_point.inclination*(Math::PI/180))*Math::sin(point.inclination*(Math::PI/180))*(1-Math::cos((point.azimuth - last_point.azimuth)*(Math::PI/180))))
                    beta = Math::acos(beta)
                    rf = (2 / beta) * Math::tan(beta / 2)
                    rc = (point.measured_depth - last_point.measured_depth) * (Math::sin(point.inclination*(Math::PI/180)) - Math::sin(last_point.inclination*(Math::PI/180)) ) / ((point.inclination - last_point.inclination)*(Math::PI/180))
                end

                md_change = point.measured_depth - last_point.measured_depth
                ns_change = (md_change)/2*((Math::sin(last_point.inclination*(Math::PI/180))*Math::cos(last_point.azimuth*(Math::PI/180)))+(Math::sin(point.inclination*(Math::PI/180))*Math::cos(point.azimuth*(Math::PI/180))))*rf
                ew_change = (md_change)/2*((Math::sin(last_point.inclination*(Math::PI/180))*Math::sin(last_point.azimuth*(Math::PI/180)))+(Math::sin(point.inclination*(Math::PI/180))*Math::sin(point.azimuth*(Math::PI/180))))*rf
                v_change = (md_change)/2*(Math::cos(last_point.inclination*(Math::PI/180))+Math::cos(point.inclination*(Math::PI/180)))*rf

                vs_change = rc * (Math::cos(last_point.inclination*(Math::PI/180)) - Math::cos(point.inclination*(Math::PI/180)))
                vs_change = (point.measured_depth - last_point.measured_depth) - (tvd + v_change- last_point.true_vertical_depth)

                puts vs_change

                tvd = tvd + v_change
                ns = ns + ns_change
                ew = ew + ew_change
                vs = vs + vs_change
                point.true_vertical_depth = tvd
                point.north_south = ns
                point.east_west = ew
                point.vertical_section = vs
            end
            last_point = point
        end

        survey_points
    end
end
