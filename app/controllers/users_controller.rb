class UsersController < ApplicationController
    include JobAnalysisHelper
    before_filter :signed_in_user, only: [:index, :show, :settings, :update]
    before_filter :signed_in_admin, only: [:destroy, :edit]
    before_filter :signed_in_support_role, only: [:new, :create]
    set_tab :users

    def index

        respond_to do |format|
            format.html { @users = User.from_company(current_user.company).includes(:district, :company).paginate(page: params[:page], limit: 20) }
            format.js {
                if params[:search].length == 0
                    @users = User.from_company(current_user.company).paginate(page: params[:page], limit: 20)
                elsif params[:search].length > 1
                    @users = User.search(params, current_user.company).results
                end
            }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                @users = User.search(params, current_user.company).results

                if @users.empty?
                    @users << User.new
                    render json: @users.map { |user| {:value => "No person found...", :name => "", :id => -1} }
                    return
                end

                if params[:q].present?
                    render json: @users.map { |user| {:name => user.name + " (" + user.title.to_s + " / " + user.district.name + ")", :id => user.id} }
                else
                    render json: @users.map { |user| {:label => user.name, :position_title => user.title.to_s, :district => user.district.present? ? user.district.name : "", :id => user.id} }
                end
            }
        end
    end

    def show
        @user = User.find_by_id(params[:id])
        not_found unless @user.company == current_user.company

        @activities = Activity.activities_for_user(@user).paginate(page: params[:page], limit: 20)

        if current_user.role.global_read? && @user != current_user
            @average_job_performance = average_job_performance @user.jobs
            @job_success_rate = job_success_rate @user.jobs
        end
    end


    def edit
        store_last_location

        @user = User.find_by_id(params[:id])
        not_found unless @user.company == current_user.company
        @districts = current_user.company.districts

        @roles = create_roles
        @divisions = current_user.company.divisions

        if !@user.product_line.nil?
            @segments = @user.product_line.segment.division.segments
            @product_lines = @user.product_line.segment.product_lines

            @product_line = @user.product_line
            @segment = @user.product_line.segment
            @division = @user.product_line.segment.division
        else
            @segments = Array.new
            @product_lines = Array.new
        end

    end

    def update

        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company

        User.transaction do
            if  @user.update_attribute(:name, params[:user][:name])
                @user.update_attribute(:location, params[:user][:location])
                @user.update_attribute(:phone_number, params[:user][:phone_number])
                @user.update_attribute(:district_id, params[:user][:district_id])
                @user.update_attribute(:role_id, params[:user][:role_id])
                @user.update_attribute(:product_line_id, params[:user][:product_line_id])


                Activity.add(self.current_user, Activity::USER_UPDATED, @user, @user.name)
                flash[:success] = "User updated"
                redirect_back_or users_path
            else
                @districts = current_user.company.districts
                @roles = create_roles
                @product_lines = current_user.company.product_lines
                render 'edit'
            end
        end
    end

    def new
        store_location

        @user = User.new
        @districts = current_user.company.districts
        @roles = create_roles
        @divisions = current_user.company.divisions
        @segments = Array.new
        @product_lines = Array.new
    end

    def create
        district_id = params[:user][:district_id]
        params[:user].delete(:district_id)

        role_id = params[:user][:role_id]
        params[:user].delete(:role_id)

        product_line_id = params[:user][:product_line_id]
        params[:user].delete(:product_line_id)

        @user = User.new(params[:user])
        @districts = current_user.company.districts
        @user.company = current_user.company
        @user.district = District.find_by_id(district_id)
        @user.role_id = role_id
        @user.product_line = ProductLine.find_by_id(product_line_id)
        password = SecureRandom.urlsafe_base64[1..7]
        @user.password = password
        @user.password_confirmation = password
        @user.create_password = true

        if @user.district.present?
            @user.time_zone = @user.district.time_zone
        end

        if @user.save

            @user.delay.send_welcome_email(@user, password)

            Activity.add(self.current_user, Activity::USER_CREATED, @user, @user.name)

            flash[:success] = "User created - #{@user.email}"

            if signed_in_admin?
                redirect_to users_path
            else
                redirect_to @user
            end
        else
            @districts = current_user.company.districts
            @roles = create_roles
            @divisions = current_user.company.divisions
            @segments = Array.new
            @product_lines = Array.new
            render 'new'
        end
    end

    def destroy
        @user = User.find_by_id(params[:id])
        not_found unless @user.company == current_user.company

        if !current_user?(@user)
            @user.destroy

            Activity.add(current_user, Activity::USER_DESTROYED, @user, @user.name)
            flash[:success] = "User destroyed."
            redirect_to users_path
        else
            flash[:error] = "Can't delete yourself."
            redirect_to users_path
        end
    end

    private
    def create_roles
        roles = []
        roles << "Select a role..."
        roles << ["", -1]
        roles << ["Support Roles"+ " (" + UserRole.support_roles(current_user.company).count.to_s + ") ------------------------", -1]
        UserRole.support_roles(current_user.company).each do |role|
            roles << [role.title, role.role_id]
        end
        roles << ["", -1]
        roles << ["Field Roles"+ " (" + UserRole.field_roles(current_user.company).count.to_s + ") ------------------------", -1]
        UserRole.field_roles(current_user.company).each do |role|
            roles << [role.title, role.role_id]
        end
        roles << ["", -1]
        roles << ["Sales Roles"+ " (" + UserRole.sales_roles(current_user.company).count.to_s + ") ------------------------", -1]
        UserRole.sales_roles(current_user.company).each do |role|
            roles << [role.title, role.role_id]
        end
        roles << ["", -1]
        roles << ["Elephant Admin Roles"+ " (" + UserRole.admin_roles(current_user.company).count.to_s + ") ------------------------", -1]
        UserRole.admin_roles(current_user.company).each do |role|
            roles << [role.title, role.role_id]
        end
        roles
    end

    def signed_in_support_role
        unless signed_in_admin? || current_user.role.global_edit?
            store_location
            redirect_to signin_url, error: "Please sign in."
        end
    end

end
