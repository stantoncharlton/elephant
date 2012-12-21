class UsersController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :settings, :update]
    before_filter :signed_in_admin, only: [:new, :create, :destroy, :edit]
    set_tab :users

    def index

        respond_to do |format|
            format.html { @users = User.from_company(current_user.company).paginate(page: params[:page], limit: 10) }
            format.js { @users = User.search(params, current_user.company).results }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                @users = User.search(params, current_user.company).results

                if params[:q].present?
                    render json: @users.map { |user| {:name => user.name + " (" + user.role.title + " / " + user.district.name + ")", :id => user.id} }
                else
                    render json: @users.map { |user| {:label => user.name, :position_title => user.role.present? ? user.role.title : "", :district => user.district.present? ? user.district.name : "", :id => user.id} }
                end
            }
        end
    end

    def settings
        @user = current_user
    end

    def show
        @user = User.find_by_id(params[:id])
        not_found unless @user.company == current_user.company

        @activities = Activity.activities_for_user(@user).paginate(page: params[:page], limit: 10)
    end


    def edit
        store_last_location

        @user = User.find_by_id(params[:id])
        not_found unless @user.company == current_user.company
        @districts = current_user.company.districts
        @roles = @roles = current_user.company.roles

        @divisions = current_user.company.divisions

        if !@user.product_line.nil?
            @segments = @user.product_line.segment.division.segments
            @product_lines = @user.product_line.segment.product_lines

            @product_line = @user.product_line
            @segment =  @user.product_line.segment
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
            if @user.update_attribute(:location, params[:user][:location])
                @user.update_attribute(:phone_number, params[:user][:phone_number])
                @user.update_attribute(:district_id, params[:user][:district_id])
                @user.update_attribute(:role_id, params[:user][:role_id])
                @user.update_attribute(:product_line_id, params[:user][:product_line_id])

                Activity.add(self.current_user, Activity::USER_UPDATED, @user, @user.name)
                flash[:success] = "User updated"
                redirect_back_or users_path
            else
                @districts = current_user.company.districts
                @roles = @roles = current_user.company.roles
                @product_lines = current_user.company.product_lines
                render 'edit'
            end
        end
    end

    def new
        store_location

        @user = User.new
        @districts = current_user.company.districts
        @roles = current_user.company.roles
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
        @user.role = UserRole.find_by_id(role_id)
        @user.product_line = ProductLine.find_by_id(product_line_id)
        password = SecureRandom.urlsafe_base64[1..7]
        @user.password = password
        @user.password_confirmation = password
        @user.create_password = true

        @user.time_zone = @user.district.time_zone

        if @user.save

            @user.delay.send_welcome_email(@user, password)

            Activity.add(self.current_user, Activity::USER_CREATED, @user, @user.name)

            flash[:success] = "User created - #{@user.email}"
            redirect_to users_path
        else
            @districts = current_user.company.districts
            @roles = @roles = current_user.company.roles
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
end
