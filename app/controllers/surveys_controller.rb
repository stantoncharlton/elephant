class SurveysController < ApplicationController

    def index
        if params[:document].present?
            @document = Document.find_by_id(params[:document])
            not_found unless !@document.nil?

            if @document.document_type == Document::SURVEY
                @survey = Survey.includes(document: {job: :well}).where(:plan => false).where("wells.id = ?", @document.job.well_id).first
            elsif @document.document_type == Document::WELL_PLAN
                @survey = Survey.includes(document: {job: :well}).where(:plan => true).where("wells.id = ?", @document.job.well_id).first
            end
            #@survey = Survey.find_by_document_id(@document.id)
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
        not_found unless @survey.present?

        if !@survey.plan? && !@survey.document.nil?
            @active_well_plan = Survey.includes(document: {job: :well}).where(:plan => true).where("wells.id = ?", @survey.document.job.well_id).first
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

            file_data = params[:file_source]
            if file_data.respond_to?(:read)
                contents = file_data.read
            elsif file_data.respond_to?(:path)
                contents = File.read(file_data.path)
            else
                logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
            end

            @survey = Survey.new(params[:survey])
            @survey.company = current_user.company
            @survey.document = @document
            @survey.plan = true
            @survey.north_type = Survey::GRID

            if @survey.name.blank?
                @survey.name = @document.name
            end

            entry_lines = []

            if !contents.blank?
                if true #Compass File
                    lines = contents.split("\r\n")

                    dividers = 0
                    lines.each_with_index do |line, index|
                        if line.start_with?(' ===')
                            dividers += 1
                        else
                            if line.start_with?('VSect. Azimuth')
                                @survey.vertical_section_azimuth = line.split(':')[1].strip!
                            elsif dividers >= 2
                                entry_lines << line
                            end
                        end
                    end
                end

                @survey.save

                entry_lines.each_with_index do |line, index|
                    parts = line.gsub('/\s+/m', ' ').strip.split(' ')
                    survey_point = SurveyPoint.new
                    survey_point.company = current_user.company
                    survey_point.user = current_user
                    survey_point.user_name = current_user.name
                    survey_point.survey = @survey
                    survey_point.comment = nil
                    survey_point.measured_depth = parts[1].to_d
                    survey_point.inclination = parts[2].to_d
                    survey_point.azimuth = parts[3].to_d
                    survey_point.course_length = parts[4].to_d
                    survey_point.true_vertical_depth = parts[5].to_d
                    survey_point.vertical_section = parts[6].to_d
                    survey_point.north_south = parts[7].to_d
                    survey_point.east_west = parts[8].to_d
                    survey_point.closure_distance = parts[9].to_d
                    survey_point.closure_angle = parts[10].to_d
                    survey_point.dog_leg_severity = parts[11].to_d
                    survey_point.save
                    survey_point
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
        @survey = Survey.find(params[:id])
        @survey_points = ''
        @import_tie_on = true
        @plan = true
    end

    def update
        @survey = Survey.find(params[:id])
        @plan = true

        SurveyPoint.transaction do

            file_data = params[:file_source]
            if file_data.respond_to?(:read)
                contents = file_data.read
            elsif file_data.respond_to?(:path)
                contents = File.read(file_data.path)
            else
                logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
            end

            @survey.north_type = Survey::GRID

            entry_lines = []

            if true #Compass File
                lines = contents.split("\r\n")

                dividers = 0
                lines.each_with_index do |line, index|
                    if line.start_with?(' ===')
                        dividers += 1
                    else
                        if line.start_with?('VSect. Azimuth')
                            @survey.vertical_section_azimuth = line.split(':')[1].strip!
                        elsif dividers >= 2
                            entry_lines << line
                        end
                    end
                end
            end

            @survey.save


            @survey.survey_points.each do |sp|
                sp.destroy
            end

            entry_lines.each_with_index do |line, index|
                parts = line.gsub('/\s+/m', ' ').strip.split(' ')
                survey_point = SurveyPoint.new
                survey_point.company = current_user.company
                survey_point.user = current_user
                survey_point.user_name = current_user.name
                survey_point.survey = @survey
                survey_point.comment = nil
                survey_point.measured_depth = parts[1].to_d
                survey_point.inclination = parts[2].to_d
                survey_point.azimuth = parts[3].to_d
                survey_point.course_length = parts[4].to_d
                survey_point.true_vertical_depth = parts[5].to_d
                survey_point.vertical_section = parts[6].to_d
                survey_point.north_south = parts[7].to_d
                survey_point.east_west = parts[8].to_d
                survey_point.closure_distance = parts[9].to_d
                survey_point.closure_angle = parts[10].to_d
                survey_point.dog_leg_severity = parts[11].to_d
                survey_point.save
                survey_point
            end
        end

        if @survey.errors.any?
            render 'edit'
        else
            redirect_to @survey
        end
    end

end
