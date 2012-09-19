class ElephantAdminController < ApplicationController
    before_filter :elephant_admin_user, only: [:index, :new_company, :new_user]

  def index

  end

  def new_company
  end

  def new_user
  end


private

    def elephant_admin_user
        redirect_to(root_path) unless signed_in? && current_user.elephant_admin?
    end
end
