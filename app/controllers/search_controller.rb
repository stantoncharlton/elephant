class SearchController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :index]


    require 'will_paginate/array'

    def index

        @term = params[:search].present? ? params[:search] : ""
        @jobs = Array.new.paginate()

        respond_to do |format|
            format.html do
                if params[:search].present?
                    @jobs = Job.search(current_user, params, current_user.company).results
                    @users = User.search(params, current_user.company).results.take(10)
                end

            end
            format.js do
                @div_name = params["div_name"]

                if params["data_type"]

                    if params["data_type"] == "1"
                        @show_fields = true
                        @fields = Well.accessible_attributes.select { |w| w != "" }
                    elsif params["data_type"] == "2"
                        @product_lines = ProductLine.from_company(current_user.company)
                        @show_fields = false
                        @fields = Array.new
                    end
                elsif params["product_line"]
                    @show_fields = false
                    @product_line = ProductLine.find_by_id(params["product_line"])
                    not_found unless @product_line.company == current_user.company

                    @job_templates = @product_line.job_templates

                elsif params["job_template"]
                    @show_fields = true

                    if params["job_template"].blank?
                        @dynamic_field = DynamicField.new(value_type:  Well.default_unit_value(params[:field].downcase))
                        render 'search/change_units'
                        return
                    else
                        @job_template = JobTemplate.find_by_id(params["job_template"])
                        not_found unless @job_template.company == current_user.company

                        if params[:field]
                            field_id = params[:field]
                            @dynamic_field = @job_template.dynamic_fields.select { |df| df.id == field_id.to_i }.first
                            render 'search/change_units'
                            return
                        end
                    end
                end

                render 'search/add_fields'
            end
        end

    end

    def new

        @query = Query.new
        @well_data = Well.accessible_attributes.select { |w| w != "" }

        @dynamic_field = DynamicField.new
        @dynamic_field.value_type = DynamicField::LENGTH_FT

        @divisions = current_user.company.divisions
        @segments = Array.new
        @product_lines = Array.new
        @job_templates = Array.new

        @division =  nil
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
        query = Query.new
        query.constraints = Array.new
        index = 0

        while true do
            if  params["query"]["constraints"][index.to_s].present?

                constraint = Constraint.new
                constraint.data_type = params["query"]["constraints"][index.to_s]["data_type"]
                constraint.job_template = params["query"]["constraints"][index.to_s]["job_template"]
                constraint.field = params["query"]["constraints"][index.to_s]["field"]
                constraint.operator = params["query"]["constraints"][index.to_s]["operator"]
                constraint.value = params["query"]["constraints"][index.to_s]["value"]
                constraint.units = params["query"]["constraints"][index.to_s]["units"]
                constraint.client_id = params["query"]["constraints"][index.to_s]["client_id"]
                constraint.district_id = params["query"]["constraints"][index.to_s]["district_id"]

                if constraint.data_type == "1" || constraint.data_type == "2"
                    if !constraint.data_type.empty? and !constraint.field.empty?
                        query.constraints << constraint
                    end
                elsif constraint.data_type == "3" and !constraint.client_id.blank?
                    query.constraints << constraint
                elsif constraint.data_type == "4" and !constraint.district_id.blank?
                    query.constraints << constraint
                end
            else
                break
            end
            index += 1
        end

        @jobs = Job.advanced_search(query, current_user.company).paginate(page: params[:page], limit: 10)
    end

end
