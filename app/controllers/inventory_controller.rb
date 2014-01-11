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
        elsif current_user.company.districts.where(:master => true).count == 1
            @district = current_user.company.districts.where(:master => true).first.districts.first
        else
            @district = nil
        end


        if @district.present?
            if current_user.role.district_read? && !@district_present
                @jobs = Job.where("jobs.district_id IN (SELECT id FROM districts where master_district_id = :district_id)", district_id: @district.id).where("jobs.status > ? AND jobs.status < 100", Job::ON_JOB).order("jobs.start_date DESC")
            else
                if current_user.role.limit_to_assigned_jobs?
                    @jobs = Job.where("jobs.id in (select job_id from job_memberships where user_id = :user_id)", user_id: current_user.id).where("jobs.status > ? AND jobs.status < 100", Job::ON_JOB).order("jobs.start_date DESC")
                else
                    @jobs = Job.where("jobs.district_id = ?", @district.id).where("jobs.status > ? AND jobs.status < 100", Job::ON_JOB).order("jobs.start_date DESC")
                end
            end
        elsif !current_user.role.limit_to_assigned_jobs?
            @jobs = Job.where("jobs.status > ? AND jobs.status < 100", Job::ON_JOB).order("jobs.start_date DESC")
        end

        if !@district.nil?
            if current_user.role.district_read?
                @parts = Part.includes(:parts).where("parts.district_id = :district_id", district_id: @district.id).where(:template => false).order("parts.name ASC")
            elsif current_user.role.limit_to_assigned_jobs?
                @parts = Part.includes(:parts).where("parts.district_id = :district_id", district_id: @district.id).where(:template => false).order("parts.name ASC")
            else
                @parts = Part.includes(:parts).where("parts.district_id = :district_id", district_id: @district.id).where(:template => false).order("parts.name ASC")
            end
        elsif !current_user.role.limit_to_assigned_jobs?
            @parts = Part.includes(:parts).where(:template => false).order("parts.name ASC")
        end

    end


    def show
        @district = District.find_by_id(params[:id])
        not_found unless @district.present? && @district.company == current_user.company

        @condensed = true

        if current_user.role.district_read?
            @parts = Part.includes(:parts).where("parts.district_id = :district_id", district_id: @district.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
        elsif current_user.role.limit_to_assigned_jobs?
            @parts = Part.includes(:parts).where("parts.district_id = :district_id", district_id: @district.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
        else
            @parts = Part.includes(:parts).where("parts.district_id = :district_id", district_id: @district.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
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
