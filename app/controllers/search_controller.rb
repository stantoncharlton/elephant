class SearchController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :index]


    require 'will_paginate/array'
    include JobsExportHelper

    def index

        @term = params[:search].present? ? params[:search] : ""
        @jobs = Array.new.paginate()

        respond_to do |format|
            format.html do
                if params[:search].present?
                    @jobs = Job.search(current_user, params, current_user.company).results
                    @users = User.search(params, current_user.company).results.take(3)
                    @districts = District.search(params, current_user.company, false).results.take(3)
                    @fields = Field.search(params, current_user.company).results.take(3)
                    @wells = Well.search(params, current_user.company).results.take(3)
                    @assets = Part.search_no_district(params, current_user.company).results.take(10)
                end
            end
            format.xlsx do
                params[:page] =
                        @jobs = Job.search(current_user, params, current_user.company, false).results
                excel = to_excel @jobs
                send_data excel.to_stream.read, :filename => 'jobs.xlsx', :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            end
            format.js do
                @div_name = params["div_name"]
                @hide_job_type = false
                @data_type = params[:data_type].to_i

                if params[:division]
                    @division = Division.find_by_id(params[:division])
                    not_found unless @division.present?
                    not_found unless @division.company == current_user.company
                end
                if params[:segment]
                    @segment = Segment.find_by_id(params[:segment])
                    not_found unless @segment.present?
                    not_found unless @segment.company == current_user.company
                end


                if params[:product_line]
                    @product_line = ProductLine.find_by_id(params[:product_line])
                    not_found unless @product_line.company == current_user.company

                    if @data_type == Query::WELL_DATA || @data_type == Query::JOB_DATA
                        @show_fields = false
                        @job_templates = @product_line.job_templates
                    elsif @data_type == Query::JOB_TOOLS
                        @show_fields = true
                        @tools = []
                        @product_line.primary_tools.each do |tool|
                            @tools << tool
                        end
                        @product_line.segment.division.secondary_tools.each do |tool|
                            @tools << tool
                        end
                    elsif @data_type == Query::FAILURE
                        @show_fields = true
                        @failures = []
                        @product_line.failures.each do |failure|
                            @failures << failure
                        end
                    end

                elsif params[:job_template]

                    if @data_type != Query::JOB_TOOLS && @data_type != Query::FAILURE
                        @show_fields = true
                        @offshore = false

                        @job_template = nil
                        if !params[:job_template].blank?
                            @job_template = JobTemplate.find_by_id(params[:job_template])
                            not_found unless @job_template.company == current_user.company
                        end

                        if params[:field]
                            begin
                                if @job_template
                                    field_id = params[:field]
                                    @dynamic_field = @job_template.dynamic_fields.select { |df| df.id == field_id.to_i }.first
                                end
                            end

                            if !@dynamic_field
                                @dynamic_field = DynamicField.new(value_type: Well.default_unit_value(params[:field].downcase))

                                @offshore = (params[:field].downcase == "offshore")
                            end

                            render 'search/change_units'
                            return
                        end
                    else
                        render :nothing => true
                        return
                    end
                else
                    if @data_type == Query::WELL_DATA
                        @well_data = Well.accessible_attributes.select { |w| !w.blank? && !Well.human_attribute_name(w).include?("value type") }
                        @show_fields = true
                    elsif @data_type == Query::JOB_DATA
                        @product_lines = ProductLine.from_company(current_user.company)
                        @show_fields = false
                    elsif @data_type == Query::JOB_TOOLS
                        @hide_job_type = true
                        @show_fields = false
                    elsif @data_type == Query::FAILURE
                        @hide_job_type = true
                        @show_fields = false
                    end
                end

                render 'search/add_fields'
            end
        end

    end

    def new

        @query = Query.new
        @query.user = current_user
        @well_data = Well.accessible_attributes.select { |w| !w.blank? && !Well.human_attribute_name(w).include?("value type") }

        @dynamic_field = DynamicField.new
        @dynamic_field.value_type = DynamicField::LENGTH_FT

        @divisions = current_user.company.divisions
        @segments = Array.new
        @product_lines = Array.new
        @job_templates = Array.new

        @division = nil
        @segment = nil
        @product_line = nil

        if current_user.product_line.present?
            @segments = current_user.product_line.segment.division.segments
            @product_lines = current_user.product_line.segment.product_lines
            @job_templates = current_user.product_line.job_templates

            @division = current_user.product_line.segment.division.id
            @segment = current_user.product_line.segment.id
            @product_line = current_user.product_line.id
        end

        respond_to do |format|
            format.html do

            end
            format.js do

            end
        end
    end

    def create
        @query = Query.new
        @query.user = current_user
        @query.constraints = Array.new
        index = 0

        if params["query"].present?
            @params_query = params["query"]["constraints"]
        end

        if params["serialized_query"].present?
            @constraints = JSON.parse params["serialized_query"].to_s
            puts @constraints
            puts "..........."
            puts @constraints["1"]
        else
            @constraints = params["query"]["constraints"]
        end

        while true do
            if  @constraints[index.to_s].present?

                constraint = Constraint.new
                constraint.data_type = @constraints[index.to_s]["data_type"].to_i
                constraint.job_template = @constraints[index.to_s]["job_template"]
                constraint.field = @constraints[index.to_s]["field"]
                constraint.operator = @constraints[index.to_s]["operator"]
                constraint.value = @constraints[index.to_s]["value"]
                if @constraints[index.to_s]["field"] == "offshore"
                    constraint.operator = "1"
                    constraint.value = "t"
                end
                constraint.units = @constraints[index.to_s]["units"]
                constraint.client_id = @constraints[index.to_s]["client_id"]
                constraint.district_id = @constraints[index.to_s]["district_id"]

                if constraint.data_type == Query::WELL_DATA || constraint.data_type == Query::JOB_DATA
                    if !constraint.field.empty?
                        @query.constraints << constraint
                    end
                elsif constraint.data_type == Query::CLIENT && !constraint.client_id.blank?
                    @query.constraints << constraint
                elsif constraint.data_type == Query::DISTRICT && !constraint.district_id.blank?
                    @query.constraints << constraint
                elsif constraint.data_type == Query::JOB_TOOLS && !constraint.field.empty?
                    @query.constraints << constraint
                elsif constraint.data_type == Query::FAILURE && !constraint.field.empty?
                    @query.constraints << constraint
                end
            else
                break
            end
            index += 1
        end

        @jobs = Job.advanced_search(@query, current_user.company)

        respond_to do |format|
            format.html do
                @jobs = @jobs.paginate(page: params[:page], limit: 20)
            end
            format.xlsx do
                excel = to_excel @jobs
                send_data excel.to_stream.read, :filename => 'jobs.xlsx', :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            end
        end
    end

end
