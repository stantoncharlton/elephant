class PartMembershipsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :destroy]

    def new
        @part_membership = PartMembership.new
    end

    def create
        job_id = params[:part_membership][:job_id]
        params[:part_membership].delete(:job_id)

        part_id = params[:part_membership][:part_id]
        params[:part_membership].delete(:part_id)

        primary_tool_id = params[:part_membership][:primary_tool_id]
        params[:part_membership].delete(:primary_tool_id)

        @part_membership = PartMembership.new(params[:part_membership])

        if @part_membership.template?
            @part_membership.primary_tool = PrimaryTool.find_by_id(primary_tool_id)
            not_found unless @part_membership.primary_tool.job_template.company == current_user.company
        else
            @part_membership.job = Job.find_by_id(job_id)
            not_found unless @part_membership.job.company == current_user.company

            @part_membership.part = Part.find_by_id(part_id)
            not_found unless @part_membership.part.company == current_user.company
        end


        if @part_membership.save && !@part_membership.template?
            @part_membership.part.status = Part::ON_JOB
            @part_membership.part.current_job =  @part_membership.job
            @part_membership.part.save
        end
    end

    def destroy
        @part_membership = PartMembership.find_by_id(params[:id])
        if @part_membership.template?
            not_found unless @part_membership.primary_tool.job_template.company == current_user.company
        else
            not_found unless @part_membership.part.company == current_user.company
        end

        if @part_membership.destroy  && !@part_membership.template?
            @part_membership.part.status = Part::AVAILABLE
            @part_membership.part.current_job = nil
            @part_membership.part.save
        end
    end

end