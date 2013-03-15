class DivisionsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:new, :create, :edit, :update, :destroy]
    set_tab :job_templates

    def index
        respond_to do |format|
            format.html {
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
        not_found unless @division.company == current_user.company

        @jobs = Division.from_company_for_user(@division, params, current_user, current_user.company).results
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
        @division.destroy

        #Activity.add(self.current_user, Activity::PRODUCT_LINE_DESTROYED, @product_line, @product_line.name)

        flash[:success] = "Division deleted."
    end
end
