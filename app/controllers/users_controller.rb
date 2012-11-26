class UsersController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :settings]
    before_filter :signed_in_admin, only: [:new, :create, :destroy, :edit, :update]
    set_tab :users

    def index

        respond_to do |format|
            format.html { @users = User.search(params, current_user.company).results }
            format.js { @users = User.search(params, current_user.company).results }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                @users = User.search(params, current_user.company).results
=begin
                @users = User.where("users.company_id = :company_id", company_id: current_user.company.id)
                            .where("lower(users.name) like", "%#{params[:term].downcase}%")
                            .order("users.name desc")
=end
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
        @roles = current_user.company.roles
    end

    def update

        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company

        User.transaction do
            if @user.update_attribute(:location, params[:user][:location])
                @user.update_attribute(:phone_number, params[:user][:phone_number])
                @user.update_attribute(:district_id, params[:user][:district_id])
                @user.update_attribute(:role_id, params[:user][:role_id])

                Activity.add(self.current_user, Activity::USER_UPDATED, @user, @user.name)
                flash[:success] = "User updated"
                redirect_back_or users_path
            else
                @districts = current_user.company.districts
                @roles = @roles = current_user.company.roles
                render 'edit'
            end
        end
    end

    def new
        store_location

        @user = User.new
        @districts = current_user.company.districts
        @roles = current_user.company.roles
    end

    def create
        district_id = params[:user][:district_id]
        params[:user].delete(:district_id)

        role_id = params[:user][:role_id]
        params[:user].delete(:role_id)

        @user = User.new(params[:user])
        @districts = current_user.company.districts
        @user.company = current_user.company
        @user.district = District.find_by_id(district_id)
        @user.role = UserRole.find_by_id(role_id)
        password = SecureRandom.urlsafe_base64[1..7]
        @user.password = password
        @user.password_confirmation = password
        @user.create_password = true

        if @user.save

            Activity.add(self.current_user, Activity::USER_CREATED, @user, @user.name)

            flash[:success] = "User created - #{@user.email}"
            redirect_to users_path
        else
            @districts = current_user.company.districts
            @roles = @roles = current_user.company.roles
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
