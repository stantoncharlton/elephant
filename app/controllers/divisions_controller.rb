class DivisionsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:new, :create, :edit, :update, :destroy]
    set_tab :job_templates

    include JobAnalysisHelper

    def index
        respond_to do |format|
            format.html {
                if params[:division_id].present?
                    @division = Division.find_by_id(params[:division_id])
                    not_found unless @division.company == current_user.company
                else
                    @divisions = Division.includes(segments: {product_lines: :job_templates}).from_company(current_user.company).order("name ASC")
                end
            }
            format.js {
                if params[:division_id].present?
                    @division = Division.find_by_id(params[:division_id])
                    not_found unless @division.company == current_user.company
                else
                    @divisions = Division.from_company(current_user.company).order("name ASC")
                end
            }
            format.json {
                @divisions = Division.search(params, current_user.company).results
                render json: @divisions.map { |division| {:name => division.name, :division_type => division.class.name.underscore.humanize, :label => division.class.name.underscore.humanize + ": " + division.name, :id => division.id} }
            }
        end
    end

    def show
        @division = Division.find_by_id(params[:id])
        not_found unless @division.present? && @division.company == current_user.company

        @is_paged = params[:page].present?
        if @is_paged
            @jobs = @division.jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :well, :job_processes, :documents, :district, :client, :job_template => {:primary_tools => :tool}).reorder('').order("jobs.created_at DESC").paginate(page: params[:page], limit: 20)
        else
            @jobs = Job.includes(job_template: {product_line: {segment: :division}}).where("jobs.company_id = :company_id AND divisions.id = :division_id", company_id: @division.company_id, division_id: @division.id).where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_closed: Job::COMPLETE, close_date: (Time.now - 5.days)).
            order("jobs.created_at DESC")
        end
    end

    def new
        @division = Division.new
    end

    def create
        @division = Division.new(params[:division])
        @division.company = current_user.company

        if @division.save

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_CREATED, @product_line, @product_line.name)

            flash[:success] = "Division created - #{@division.name}"
            #redirect_to job_template_path_path
        else
            render 'error'
        end
    end

    def edit
        @division = Division.find(params[:id])
        not_found unless @division.company == current_user.company
    end

    def update

        @division = Division.find(params[:id])
        not_found unless @division.company == current_user.company

        if @division.update_attributes(params[:division])

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_UPDATED, @product_line, @product_line.name)

            flash[:success] = "Division updated"
            #redirect_to job_templates_path
        else
            render 'edit'
        end
    end

    def destroy
        @division = Division.find(params[:id])
        not_found unless @division.company == current_user.company

        if current_user.company.jobs.includes(job_template: {product_line: {segment: :division}}).where("divisions.id = ?", @division.id).any?
            render 'job_templates/elephant_destroy'
            return
        else
            @division.destroy
            #Activity.add(self.current_user, Activity::PRODUCT_LINE_DESTROYED, @product_line, @product_line.name)
            flash[:success] = "Division deleted."
        end
    end
end
