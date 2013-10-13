class SurveyPoint < ActiveRecord::Base
    attr_accessible :measured_depth,
                    :inclination,
                    :azimuth,
                    :tie_on,
                    :true_vertical_depth,
                    :east_west,
                    :north_south,
                    :vertical_section,
                    :comment

    belongs_to :company
    belongs_to :survey


    def self.create survey, comment, measured_depth, inclination, azimuth
        survey_point = SurveyPoint.new
        survey_point.company = survey.company
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
