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

        survey_points.each do |point|
            point = Survey.calculate_point point, last_point
            last_point = point
        end

        survey_points
    end

    def self.calculate_point point, last_point
        rc = 1.0
        rf = 1.0

        if point.tie_on

        elsif last_point.nil?
            point.true_vertical_depth = 0.0
            point.north_south = 0.0
            point.east_west = 0.0
        else
            if point.inclination - last_point.inclination != 0 || point.azimuth - last_point.azimuth != 0
                beta = Math::cos((point.inclination - last_point.inclination)*(Math::PI/180))-(Math::sin(last_point.inclination*(Math::PI/180))*Math::sin(point.inclination*(Math::PI/180))*(1-Math::cos((point.azimuth - last_point.azimuth)*(Math::PI/180))))
                beta = Math::acos(beta)
                rf = (2 / beta) * Math::tan(beta / 2)
                #rc = (point.measured_depth - last_point.measured_depth) * (Math::sin(point.inclination*(Math::PI/180)) - Math::sin(last_point.inclination*(Math::PI/180)) ) / ((point.inclination - last_point.inclination)*(Math::PI/180))
            end

            md_change = point.measured_depth - last_point.measured_depth
            ns_change = (md_change)/2*((Math::sin(last_point.inclination*(Math::PI/180))*Math::cos(last_point.azimuth*(Math::PI/180)))+(Math::sin(point.inclination*(Math::PI/180))*Math::cos(point.azimuth*(Math::PI/180))))*rf
            ew_change = (md_change)/2*((Math::sin(last_point.inclination*(Math::PI/180))*Math::sin(last_point.azimuth*(Math::PI/180)))+(Math::sin(point.inclination*(Math::PI/180))*Math::sin(point.azimuth*(Math::PI/180))))*rf
            v_change = (md_change)/2*(Math::cos(last_point.inclination*(Math::PI/180))+Math::cos(point.inclination*(Math::PI/180)))*rf

            point.true_vertical_depth = last_point.true_vertical_depth + v_change
            point.north_south = last_point.north_south + ns_change
            point.east_west = last_point.east_west + ew_change
        end

        cd = Math::sqrt((point.east_west * point.east_west) + (point.north_south * point.north_south))
        ca = Math::atan(point.east_west  / point.north_south)
        point.vertical_section = cd# * Math::cos(ca - point.azimuth)

        point
    end
end
