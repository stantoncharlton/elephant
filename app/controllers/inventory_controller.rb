class InventoryController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:index]
    set_tab :inventory

    def index

        job_process_sql = JobProcess.select("job_processes.id").where("job_processes.company_id = ?", current_user.company_id).order("job_processes.created_at ASC").limit(5).to_sql
        @jobs = Job.where("jobs.id IN (#{job_process_sql})").order("jobs.created_at DESC")

        if params[:district].present?
            @district = District.find_by_id(params[:district])
            not_found unless @district.company == current_user.company
        elsif current_user.district.present?
            @district = current_user.district
        else
            redirect_to root_path
        end

    end

end
