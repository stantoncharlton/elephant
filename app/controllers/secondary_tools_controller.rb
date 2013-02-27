class SecondaryToolsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :new, :create, :destroy]

    set_tab :tools

    def index

        if params[:division]
            @division = Division.find_by_id(params[:division])
            not_found unless @division.company == current_user.company
        end

        render 'tools/secondary/index'
    end

    def new

    end

    def create
        tool_id = params[:secondary_tool][:tool_id]
        params[:secondary_tool].delete(:tool_id)

        job_id = params[:secondary_tool][:job_id]
        params[:secondary_tool].delete(:job_id)

        @tool = SecondaryTool.new(params[:secondary_tool])
        @tool.tool = Tool.find_by_id(tool_id)
        not_found unless @tool.tool.company == current_user.company
        @tool.job = Job.find_by_id(job_id)
        not_found unless @tool.job.company == current_user.company

        @tool.save

        render 'tools/secondary/secondary_create'
    end

    def destroy
        @tool = SecondaryTool.find_by_id(params[:id])
        not_found unless  @tool.tool.company == current_user.company
        @tool.destroy

        render 'tools/secondary/secondary_destroy'
    end
end
