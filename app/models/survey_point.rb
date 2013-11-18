class SurveyPoint < ActiveRecord::Base
    attr_accessible :measured_depth,
                    :inclination,
                    :azimuth,
                    :course_length,
                    :tie_on,
                    :true_vertical_depth,
                    :east_west,
                    :north_south,
                    :vertical_section,
                    :dog_leg_severity,
                    :closure_distance,
                    :closure_angle,
                    :comment,
                    :user_name

    belongs_to :company
    belongs_to :survey
    belongs_to :user


    def self.create survey, user, comment, measured_depth, inclination, azimuth
        survey_point = SurveyPoint.new
        survey_point.company = survey.company
        survey_point.user = user
        survey_point.user_name = user.name
        survey_point.survey = survey
        survey_point.comment = comment
        survey_point.tie_on = false
        survey_point.measured_depth = measured_depth
        survey_point.inclination = inclination
        survey_point.azimuth = azimuth
        survey_point.save
        survey_point
    end

end
