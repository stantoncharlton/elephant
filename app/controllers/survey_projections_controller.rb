class SurveyProjectionsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create]

    include ActionView::Helpers::NumberHelper

    def new
        @survey = Survey.find_by_id(params[:survey])
        not_found unless @survey.present?
    end

    def create
        @survey = Survey.find_by_id(params[:survey])
        not_found unless @survey.present?

        @drilling_log = @survey.document.job.drilling_log
        @well_plans = Survey.includes(document: {job: :well}).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).order("surveys.created_at ASC")
        if @survey.present?
            @active_well_plan = @well_plans.where("surveys.well_plan_for_survey_id = ?", @survey.id).last
        end
        if @active_well_plan.nil?
            @active_well_plan = @well_plans.last
        end

        calculated_points = @survey.no_well_plan ? [] : @active_well_plan.survey_points
        calculated_points_survey = @survey.calculated_points(@survey.no_well_plan ? 0 : @active_well_plan.vertical_section_azimuth)

        last_point = calculated_points_survey.last

        case params[:type]
            when "current"
            when "target"
            when "bit"
                bha = @drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id IS NOT NULL").last
                @md = number_with_delimiter(last_point.measured_depth + (bha.present? && bha.bha.present? && bha.bha.bit_to_sensor.present? ? bha.bha.bit_to_sensor : 0.0), :delimiter => ',')
                @inc = last_point.inclination.round(2)
                @azi = last_point.azimuth.round(2)
                @tvd = number_with_delimiter(last_point.true_vertical_depth.round(2), :delimiter => ',')
                @dls = last_point.dog_leg_severity.round(2)
            when "md"
            when "tvd"
        end

    end

end
