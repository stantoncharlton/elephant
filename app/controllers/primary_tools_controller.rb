class PrimaryToolsController < ApplicationController
    before_filter :signed_in_admin, only: [:create, :destroy]
    before_filter :signed_in_user, only: [:show]



    def show
        @primary_tool = PrimaryTool.find_by_id(params[:id])
        not_found unless @primary_tool.tool.company == current_user.company

        job_templates_query = PrimaryTool.select("primary_tools.job_template_id").where("primary_tools.tool_id = ?", @primary_tool.tool_id).uniq.to_sql
        @jobs = Job.where("jobs.job_template_id IN (#{job_templates_query})").paginate(page: params[:page], limit: 20)
    end

    def create

        tool_id = params[:primary_tool][:tool_id]
        params[:primary_tool].delete(:tool_id)

        job_template_id = params[:primary_tool][:job_template_id]
        params[:primary_tool].delete(:job_template_id)

        @tool = PrimaryTool.new(params[:primary_tool])
        @tool.tool = Tool.find_by_id(tool_id)
        not_found unless @tool.tool.present? &&  @tool.tool.company == current_user.company
        @tool.job_template = JobTemplate.find_by_id(job_template_id)
        not_found unless @tool.job_template.company == current_user.company
        @tool.company = current_user.company

        @tool.save

        render 'tools/primary/primary_create'
    end

    def destroy
        @tool = PrimaryTool.find_by_id(params[:id])
        not_found unless  @tool.tool.company == current_user.company
        @tool.destroy

        render 'tools/primary/primary_destroy'
    end

end
