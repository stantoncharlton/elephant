class SegmentsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:new, :create, :edit, :update, :destroy]

    respond_to :js

    def index
        if params[:segment_id].present?
            @segment = Segment.find_by_id(params[:segment_id])
            not_found unless @segment.company == current_user.company
        else
            @segments = Segment.from_company(current_user.company).order("name ASC")
        end

    end

    def show

        @segment = Segment.find_by_id(params[:id])
        not_found unless @segment.company == current_user.company

        @is_paged = params[:page].present?
        if @is_paged
            @jobs = @segment.jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :well, :job_processes, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).reorder('').order("jobs.created_at DESC").paginate(page: params[:page], limit: 20)
        else
            @jobs = @segment.jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :well, :job_processes, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).reorder('').where("jobs.status = :status_active OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_active: Job::ACTIVE, status_closed: Job::CLOSED, close_date: (Time.now - 5.days)).
                    order("jobs.created_at DESC")
        end
    end

    def new
        @segment = Segment.new
        division = Division.find_by_id(params[:division])
        not_found unless division.company == current_user.company
        @segment.division = division
    end

    def create
        division = Division.find_by_id(params[:segment][:division_id])
        not_found unless division.company == current_user.company
        params[:segment].delete(:division_id)

        @segment = Segment.new(params[:segment])
        @segment.division = division
        @segment.company = current_user.company

        if @segment.save

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_CREATED, @product_line, @product_line.name)

            flash[:success] = "Segment created - #{@segment.name}"
            #redirect_to job_template_path_path
        else
            render 'error'
        end
    end

    def edit
        @segment = Segment.find(params[:id])
        not_found unless @segment.company == current_user.company
    end

    def update

        @segment = Segment.find(params[:id])
        not_found unless @segment.company == current_user.company

        if @segment.update_attributes(params[:segment])

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_UPDATED, @product_line, @product_line.name)

            flash[:success] = "Segment updated"
            #redirect_to job_templates_path
        else
            render 'edit'
        end
    end

    def destroy
        @segment = Segment.find(params[:id])
        not_found unless @segment.company == current_user.company

        if current_user.company.jobs.includes(job_template: {product_line: :segment}).where("segments.id = ?", @segment.id).any?
            render 'job_templates/elephant_destroy'
            return
        else
            @segment.destroy
            #Activity.add(self.current_user, Activity::PRODUCT_LINE_DESTROYED, @product_line, @product_line.name)
            flash[:success] = "Segment deleted"
        end
    end
end
