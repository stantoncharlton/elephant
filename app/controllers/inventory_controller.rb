class InventoryController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:index, :show]
    set_tab :inventory

    include InventoryHelper


    def index

        if params[:district].present?
            @district_present = true
            @district = District.find_by_id(params[:district])
            not_found unless @district.company == current_user.company
        elsif current_user.district.present?
            @district = current_user.district
        else
            @district = nil
        end


        if @district.present?
            if current_user.role.district_read? && !@district_present
                job_process_sql = JobProcess.select("job_processes.job_id").where("job_processes.event_type = ?", JobProcess::APPROVED_TO_SHIP).where("job_processes.company_id = ?", current_user.company_id).where("jobs.district_id IN (SELECT id FROM districts where master_district_id = :district_id)", district_id: @district.id).order("job_processes.created_at DESC").limit(5).to_sql
                @jobs = Job.where("jobs.id IN (#{job_process_sql})")
            else
                if current_user.role.limit_to_assigned_jobs?
                    job_process_sql = JobProcess.select("job_processes.job_id").where("job_processes.event_type = ?", JobProcess::APPROVED_TO_SHIP).where("job_processes.company_id = ?", current_user.company_id).where("jobs.id in (select job_id from job_memberships where user_id = :user_id)", user_id: current_user.id).order("job_processes.created_at DESC").limit(5).to_sql
                    @jobs = Job.where("jobs.id IN (#{job_process_sql})")
                else
                    job_process_sql = JobProcess.select("job_processes.job_id").where("job_processes.event_type = ?", JobProcess::APPROVED_TO_SHIP).where("job_processes.company_id = ?", current_user.company_id).where("jobs.district_id = ?", @district.id).order("job_processes.created_at DESC").limit(5).to_sql
                    @jobs = Job.where("jobs.id IN (#{job_process_sql})")
                end
            end
        elsif !current_user.role.limit_to_assigned_jobs?
            job_process_sql = JobProcess.select("job_processes.job_id").where("job_processes.event_type = ?", JobProcess::APPROVED_TO_SHIP).where("job_processes.company_id = ?", current_user.company_id).order("job_processes.created_at DESC").limit(5).to_sql
            @jobs = Job.where("jobs.id IN (#{job_process_sql})")
        end

        if !@district.nil?
            if current_user.role.district_read?
                @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where("parts.warehouse_id IN (SELECT id FROM warehouses where district_id = :district_id)", district_id: @district.id).where(:template => false).order("parts.name ASC")
            elsif current_user.role.limit_to_assigned_jobs?
                @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where("parts.warehouse_id IN (SELECT warehouse_id FROM warehouse_memberships where user_id = :user_id)", user_id: current_user.id).where(:template => false).order("parts.name ASC")
            else
                @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where("parts.warehouse_id IN (SELECT id FROM warehouses where district_id = :district_id)", district_id: @district.id).where(:template => false).order("parts.name ASC")
            end
        elsif !current_user.role.limit_to_assigned_jobs?
            @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where(:template => false).order("parts.name ASC")
        end

    end


    def show
        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company

        @condensed = true

        if current_user.role.district_read?
            @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where("parts.warehouse_id IN (SELECT id FROM warehouses where district_id = :district_id)", district_id: @district.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
        elsif current_user.role.limit_to_assigned_jobs?
            @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where("parts.warehouse_id IN (SELECT warehouse_id FROM warehouse_memberships where user_id = :user_id)", user_id: current_user.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
        else
            @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where("parts.warehouse_id IN (SELECT id FROM warehouses where district_id = :district_id)", district_id: @district.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
        end

        respond_to do |format|
            format.html {

            }
            format.xlsx {
                excel = parts_to_excel @parts
                send_data excel.to_stream.read, :filename => "Inventory List.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end

    end

end
