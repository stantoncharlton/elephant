class ProductLinesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:new, :create, :edit, :update, :destroy]

    respond_to :js

    def index
        @job_templates = []

        if params[:product_line_id].present?
            product_line = ProductLine.find_by_id(params[:product_line_id])
            if product_line.company == current_user.company
                @job_templates = product_line.job_templates
            end
        end
    end

    def show

        @product_line = ProductLine.find_by_id(params[:id])
        not_found unless @product_line.company == current_user.company

        @is_paged = params[:page].present?
        if @is_paged
            @jobs = @product_line.jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :well, :job_processes, :documents, :district, :client, :job_template => { :primary_tools => :tool }).includes(job_template: { product_line: { segment: :division } }).reorder('').order("jobs.created_at DESC").paginate(page: params[:page], limit: 20)
        else
            @jobs = @product_line.jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :well, :job_processes, :documents, :district, :client, :job_template => { :primary_tools => :tool }).includes(job_template: { product_line: { segment: :division } }).reorder('').where("jobs.status = :status_active OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_active: Job::ACTIVE, status_closed: Job::CLOSED, close_date: (Time.now - 5.days)).
                    order("jobs.created_at DESC")
        end
    end

    def new
        @product_line = ProductLine.new

        segment = Segment.find_by_id(params[:segment])
        not_found unless segment.company == current_user.company
        @product_line.segment = segment
    end

    def create
        segment = Segment.find_by_id(params[:product_line][:segment_id])
        not_found unless segment.company == current_user.company
        params[:product_line].delete(:segment_id)

        @product_line = ProductLine.new(params[:product_line])
        @product_line.company = current_user.company
        @product_line.segment = segment

        if @product_line.save

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_CREATED, @product_line, @product_line.name)

            flash[:success] = "Product Line created - #{@product_line.name}"
            #redirect_to job_template_path_path
        else
            render 'error'
        end
    end

    def edit
        @product_line = ProductLine.find(params[:id])
        not_found unless @product_line.company == current_user.company
    end

    def update

        @product_line = ProductLine.find(params[:id])
        not_found unless @product_line.company == current_user.company

        if @product_line.update_attributes(params[:product_line])

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_UPDATED, @product_line, @product_line.name)

            flash[:success] = "Product Line updated"
            #redirect_to job_templates_path
        else
            render 'edit'
        end
    end

    def destroy
        @product_line = ProductLine.find(params[:id])
        not_found unless @product_line.company == current_user.company
        @product_line.destroy

        #Activity.add(self.current_user, Activity::PRODUCT_LINE_DESTROYED, @product_line, @product_line.name)

        flash[:success] = "Product Line deleted."
    end
end
