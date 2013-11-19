class SurveyPointsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :destroy]

    def new
        @survey_point = SurveyPoint.new
    end

    def create
        survey_id = params[:survey_point][:survey_id]
        params[:survey_point].delete(:survey_id)

        @survey = Survey.find_by_id(survey_id)
        @well_plan = Survey.where(:plan => true).where("jobs.id = ?", @survey.document.job_id).first
        @survey_points = @survey.calculated_points
        @last_point = @survey_points.last

        @survey_point = SurveyPoint.new(params[:survey_point])
        @survey_point.survey = @survey
        @survey_point.company = @survey.company
        @survey_point.user = current_user
        @survey_point.user_name = current_user.name
        @survey_point.survey = @survey
        @survey_point.tie_on = false

        @survey_point.save

        @survey_points << @survey_point

        @survey_point = Survey.calculate_point @survey_point, @last_point, calculate_point
    end

    def destroy
        @survey_point = SurveyPoint.find_by_id(params[:id])
        @survey_point.destroy
    end
end
