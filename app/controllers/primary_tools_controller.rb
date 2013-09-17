class PrimaryToolsController < ApplicationController
    before_filter :signed_in_user, only: [:show, :create, :destroy]


    def show
        @primary_tool = PrimaryTool.find_by_id(params[:id])
        not_found unless @primary_tool.tool.company == current_user.company

        job_templates_query = PrimaryTool.select("primary_tools.job_template_id").where("primary_tools.tool_id = ?", @primary_tool.tool_id).uniq.to_sql
        @jobs = Job.where("jobs.job_template_id IN (#{job_templates_query})").paginate(page: params[:page], limit: 20)
    end

    def create
        if params[:duplicate].present? && params[:duplicate] == "true"
            @existing_tool = PrimaryTool.find_by_id(params[:id])

            PrimaryTool.transaction do
                @tool = PrimaryTool.new
                @tool.tool = @existing_tool.tool
                @tool.job = Job.find_by_id(params[:job_id])
                not_found unless @tool.job.company == current_user.company
                @tool.job_template = @existing_tool.job_template
                @tool.company = current_user.company

                if @tool.save
                    @existing_tool.documents.order("created_at ASC").each do |document|
                        new_document = document.duplicate
                        new_document.url = nil
                        new_document.primary_tool_id = @tool.id
                        new_document.save
                    end
                    @existing_tool.part_memberships.where(:template => true).order("created_at ASC").each do |part_membership|
                        new_part_membership = part_membership.duplicate
                        new_part_membership.part = nil
                        new_part_membership.template = true
                        new_part_membership.primary_tool = @tool
                        new_part_membership.optional = true
                        new_part_membership.save
                    end
                end
            end

            @job_editable = @tool.job.is_job_editable?(current_user)

            render 'tools/primary/duplicate'
        elsif signed_in_admin?
            tool_id = params[:primary_tool][:tool_id]
            params[:primary_tool].delete(:tool_id)

            job_template_id = params[:primary_tool][:job_template_id]
            params[:primary_tool].delete(:job_template_id)

            @tool = PrimaryTool.new(params[:primary_tool])
            @tool.tool = Tool.find_by_id(tool_id)
            not_found unless @tool.tool.present? && @tool.tool.company == current_user.company
            @tool.job_template = JobTemplate.find_by_id(job_template_id)
            not_found unless @tool.job_template.company == current_user.company
            @tool.company = current_user.company

            @tool.save

            render 'tools/primary/primary_create'
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
