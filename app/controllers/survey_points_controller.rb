class SurveyPointsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new
        @survey_point = SurveyPoint.new
    end

    def create
        survey_id = params[:survey_point][:survey_id]
        params[:survey_point].delete(:survey_id)

        @survey = Survey.find_by_id(survey_id)
        @well_plan = Survey.includes(document: {job: :well}).where(:plan => true).where("wells.id = ?", @survey.document.job.well_id).first

        @survey_point = SurveyPoint.new(params[:survey_point])
        @survey_point.survey = @survey
        @survey_point.company = @survey.company
        @survey_point.user = current_user
        @survey_point.user_name = current_user.name

        if params[:tie_in].present? && params[:tie_in] == "true"
            Survey.transaction do
                if !params[:gyro_company].blank? &&
                        !params[:gyro_date].blank? &&
                        !params[:mfs].blank? &&
                        !params[:mda].blank?

                    @survey.gyro_company = params[:gyro_company]
                    @survey.gyro_date = Time.strptime("#{params[:gyro_date]}", '%m/%d/%Y').in_time_zone(Time.zone)
                    @survey.magnetic_field_strength = params[:mfs]
                    @survey.magnetic_dip_angle = params[:mda]
                    @survey.gravity_total = 1.0
                    @survey.save

                    @survey_point.course_length = 0.0
                    @survey_point.measured_depth = params[:md].to_f
                    @survey_point.inclination = params[:i].to_f
                    @survey_point.azimuth = params[:a].to_f
                    @survey_point.true_vertical_depth = params[:tvd].to_f
                    @survey_point.vertical_section = params[:vs].to_f
                    @survey_point.dog_leg_severity = params[:dls].to_f
                    @survey_point.north_south = params[:ns].to_f
                    @survey_point.east_west = params[:ew].to_f
                    @survey_point.tie_on = true
                    @survey_point.comment = "Tie On"
                    @survey_point.save
                else
                    @survey_point.errors.add(:survey, "Tie-In fields can't be empty")
                end
            end
        else
            @survey_point.tie_on = false
            @survey_point.save
        end

    end

    def edit
        @survey_point = SurveyPoint.find_by_id(params[:id])
    end

    def update
        @survey_point = SurveyPoint.find_by_id(params[:id])
        @survey_point.update_attributes(params[:survey_point])
    end

    def destroy
        @survey_point = SurveyPoint.find_by_id(params[:id])
        @survey_point.destroy
    end
end
