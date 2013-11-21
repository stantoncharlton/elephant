class PrimaryToolsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :create, :update, :destroy]

    include JobsHelper

    def index
        @job = Job.find_by_id(params[:job])
        not_found unless @job.company == current_user.company

        respond_to do |format|
            format.xlsx {
                excel = primary_tools_to_excel @job
                send_data excel.to_stream.read, :filename => "#{@job.field.name} | #{@job.well.name} - Tools/Assets.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end
    end

    def show
        @primary_tool = PrimaryTool.find_by_id(params[:id])
        not_found unless @primary_tool.present? && @primary_tool.tool.company == current_user.company

        job_templates_query = PrimaryTool.select("primary_tools.job_template_id").where("primary_tools.tool_id = ?", @primary_tool.tool_id).uniq.to_sql
        @jobs = Job.where("jobs.job_template_id IN (#{job_templates_query})").paginate(page: params[:page], limit: 20)
    end

    def create
        if params[:duplicate].present? && params[:duplicate] == "true"
            @existing_tool = PrimaryTool.find_by_id(params[:id])
            if @existing_tool.present?
                @tool = @existing_tool.duplicate Job.find_by_id(params[:job_id]), current_user
                @job_editable = @tool.job.is_job_editable?(current_user)
            end
            render 'tools/primary/duplicate'
        elsif signed_in_admin?
            tool_id = params[:primary_tool][:tool_id]
            params[:primary_tool].delete(:tool_id)

            job_template_id = params[:primary_tool][:job_template_id]
            params[:primary_tool].delete(:job_template_id)

            @tool = PrimaryTool.new(params[:primary_tool])
            @tool.template = true
            @tool.tool = Tool.find_by_id(tool_id)
            not_found unless @tool.tool.present? && @tool.tool.company == current_user.company
            @tool.job_template = JobTemplate.find_by_id(job_template_id)
            not_found unless @tool.job_template.company == current_user.company
            @tool.company = current_user.company

            @tool.save

            render 'tools/primary/primary_create'
        end
    end

    def update
        @tool = PrimaryTool.find_by_id(params[:id])
        not_found unless  @tool.tool.company == current_user.company
        if !@tool.template?
            if params[:comments].present?
                @tool.update_attribute(:comments, params[:comments])
                render 'tools/primary/update'
            elsif params[:simple_tracking].present?
                @tool.update_attribute(:simple_tracking, true)
                @update_tool = true
                render 'tools/primary/update'
            elsif params[:advanced_tracking].present?
                @tool.update_attribute(:simple_tracking, false)
                @update_tool = true
                render 'tools/primary/update'
            elsif params[:serial].present?
                @update_tool = true
                @tracking = true
                @tool.update_attribute(:serial_number, params[:serial])
                render :nothing => true, :status => 200
            elsif params[:received].present?
                @update_tool = true
                @tracking = true
                if params[:received] == "true" && !@tool.serial_number.blank?
                    @tool.update_attribute(:received, true)
                end
                render 'tools/primary/update'
            end
        end
    end

    def destroy
        if signed_in_admin?
            @tool = PrimaryTool.find_by_id(params[:id])
            not_found unless  @tool.tool.company == current_user.company
            @tool.destroy

            render 'tools/primary/primary_destroy'
        else
            @tool = PrimaryTool.find_by_id(params[:id])
            not_found unless  @tool.tool.company == current_user.company
            if @tool.job.present?
                @tool.destroy
                render 'tools/primary/primary_destroy'
            end
        end
    end

end
