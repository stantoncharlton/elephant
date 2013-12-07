class SurveyPointsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new
        @survey_point = SurveyPoint.new
    end

    def create
        survey_id = params[:survey_point][:survey_id]
        params[:survey_point].delete(:survey_id)

        @survey = Survey.find_by_id(survey_id)
        @well_plan = Survey.includes(:document => :job).where(:plan => true).where("jobs.id = ?", @survey.document.job_id).first

        @survey_point = SurveyPoint.new(params[:survey_point])
        @survey_point.survey = @survey
        @survey_point.company = @survey.company
        @survey_point.user = current_user
        @survey_point.user_name = current_user.name

        if params[:tie_in].present? && params[:tie_in] == "true"
            Survey.transaction do
                @survey.gyro_company = params[:gyro_company]
                @survey.gyro_date = Time.strptime("#{params[:gyro_date]}", '%m/%d/%Y').in_time_zone(Time.zone)
                @survey.magnetic_field_strength = params[:mfs]
                @survey.magnetic_dip_angle = params[:mda]
                @survey.gravity_total = 1.0
                @survey.save

                @survey_point.course_length = 0.0
                @survey_point.measured_depth = params[:md]
                @survey_point.inclination = params[:i]
                @survey_point.azimuth = params[:a]
                @survey_point.true_vertical_depth = params[:tvd]
                @survey_point.vertical_section = params[:vs]
                @survey_point.dog_leg_severity = params[:dls]
                @survey_point.north_south = params[:ns]
                @survey_point.east_west = params[:ew]
                @survey_point.tie_on = true
                @survey_point.comment = "Tie On"
                @survey_point.save
            end
        else
            @survey_point.tie_on = false
            @survey_point.save
        end

    end

    def edit

    end

    def update

    end

    def destroy
        @survey_point = SurveyPoint.find_by_id(params[:id])
        @survey_point.destroy
    end
end
