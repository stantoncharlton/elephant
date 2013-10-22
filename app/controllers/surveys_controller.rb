class SurveysController < ApplicationController

    def index
        if params[:document].present?
            @document = Document.find_by_id(params[:document])
            @survey = Survey.find_by_document_id(@document.id)
            if @survey.nil?
                if @document.document_type == Document::SURVEY
                    @survey = Survey.new(name: @document.name, plan: false)
                    @survey.company = current_user.company
                    @survey.document = @document
                    @survey.save
                    redirect_to @survey
                else
                    redirect_to new_survey_path(document_id: @document)
                end
            else
                redirect_to @survey
            end
        end
    end

    def show
        @survey = Survey.find(params[:id])

        if !@survey.plan? && !@survey.document.nil?
            @active_well_plan = Survey.includes(:document => :job).where(:plan => true).where("jobs.id = ?", @survey.document.job_id).first
            render 'surveys/show_entry'
        else
            render 'surveys/show'
        end
    end

    def new
        @survey = Survey.new
        @survey_points = ''
        @import_tie_on = true
        @plan = true

        if params[:document_id].present?
            @document = Document.find_by_id(params[:document_id])
        end

        if params["modal"].present? && params["modal"] == "true"
            render 'surveys/new_modal'
        else
            render 'surveys/new'
        end
    end

    def create
        if params[:document_id].present?
            @document = Document.find_by_id(params[:document_id])
            not_found unless @document.company == current_user.company
        end

        Survey.transaction do
            @survey = Survey.new(params[:survey])
            @survey.company = current_user.company
            @survey.document = @document
            @survey.plan = true

            if @survey.name.blank?
                @survey.name = @document.name
            end

            #if params[:active_well].present? && params[:active_well] == "true"
            #    @survey.name = "Active Well Plan"
            #end

            @survey.save

            @import_tie_on = params[:import_tie_on] == "true"
            @survey_points = params[:points]
            lines = @survey_points.split("\r\n")
            SurveyPoint.transaction do
                lines.each_with_index do |line, index|
                    parts = line.split("\t")
                    survey_point = nil
                    if parts.count >= 4
                        survey_point = SurveyPoint.create @survey, current_user, parts[0], parts[1], parts[2], parts[3]
                    elsif parts.count == 3
                        survey_point = SurveyPoint.create @survey, current_user, nil, parts[0], parts[1], parts[2]
                    end

                    if @import_tie_on && index ==0
                        survey_point.tie_on = true
                        survey_point.true_vertical_depth = parts[4]
                        survey_point.vertical_section = parts[5]
                        survey_point.north_south = parts[6]
                        survey_point.east_west = parts[7]
                        survey_point.save

                    end
                end
            end

            if @survey.errors.any?
                render 'new'
            else
                if params[:active_well].present? && params[:active_well] == "true"
                    render 'surveys/create_modal'
                else
                    redirect_to @survey
                end
            end
        end
    end


    def edit
        @import_tie_on = true
    end

end
