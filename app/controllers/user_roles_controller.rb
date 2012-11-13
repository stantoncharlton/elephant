class UserRolesController < ApplicationController
    before_filter :signed_in_admin, only: [:index, :new, :create, :edit, :update, :destroy]

    set_tab :roles


    def index
        @roles = UserRole.from_company(current_user.company)
    end

    def new
        @role = UserRole.new
    end

    def create
        @role = UserRole.new(params[:user_role])
        @role.company = current_user.company

        if @role.save
            #Activity.add(self.current_user, Activity::USER_CREATED, @user, @user.name)
            flash[:success] = "User Role created"
            redirect_to user_roles_path
        else
            render 'new'
        end
    end

    def edit
        @role = UserRole.find_by_id(params[:id])
        not_found unless @role.company == current_user.company
    end

    def update
        @role = UserRole.find(params[:id])
        not_found unless @role.company == current_user.company
    end

    def destroy
        @role = UserRole.find(params[:id])
        not_found unless @role.company == current_user.company

        if @role.destroy
            flash[:success] = "Role destroyed."
            redirect_to user_roles_path
        else
            flash[:error] = "Role deleted."
            redirect_to user_roles_path
        end
    end


end
