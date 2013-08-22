class InventoryController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:index, :show]
    set_tab :inventory

    def index

        if params[:district].present?
            @district = District.find_by_id(params[:district])
            not_found unless @district.company == current_user.company
        elsif current_user.district.present?
            @district = current_user.district
        else
            @district = nil
        end

        if @district.present?
            @average_redress = PartRedress.includes(:job).where("part_redresses.company_id = ?", current_user.company_id).where("jobs.district_id = ?", @district.id).average("part_redresses.finished_redress_at - part_redresses.received_at").to_f.round(1)

            job_process_sql = JobProcess.select("job_processes.job_id").where("job_processes.event_type = ?", JobProcess::APPROVED_TO_SHIP).where("job_processes.company_id = ?", current_user.company_id).where("jobs.district_id = ?", @district.id).order("job_processes.created_at DESC").limit(5).to_sql
            @jobs = Job.where("jobs.id IN (#{job_process_sql})")
        else
            @average_redress = PartRedress.includes(:job).where("part_redresses.company_id = ?", current_user.company_id).average("part_redresses.finished_redress_at - part_redresses.received_at").to_f.round(1)

            job_process_sql = JobProcess.select("job_processes.job_id").where("job_processes.event_type = ?", JobProcess::APPROVED_TO_SHIP).where("job_processes.company_id = ?", current_user.company_id).order("job_processes.created_at DESC").limit(5).to_sql
            @jobs = Job.where("jobs.id IN (#{job_process_sql})")
        end
    end


    def show
        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company

        @parts = Part.includes(:parts).where(:company_id =>  current_user.company_id).where(:district_id => @district.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)

    end

end
