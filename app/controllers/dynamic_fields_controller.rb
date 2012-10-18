class DynamicFieldsController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :update, :destroy]

    respond_to :js

    def new
        @dynamic_field = DynamicField.new(params[:dynamic_field])
    end

    def create

        job_template_id = params[:dynamic_field][:job_template_id]
        params[:dynamic_field].delete(:job_template_id)

        @dynamic_field = DynamicField.new(params[:dynamic_field])
        @dynamic_field.company = current_user.company
        @dynamic_field.job_template_id = job_template_id

        if !@dynamic_field.save
            render 'error'
        end

        Activity.add(self.current_user, Activity::DYNAMIC_FIELD_CREATED, @dynamic_field, @dynamic_field.name)

    end

    def update
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @document.company == current_user.company

        # todo
    end


    def destroy
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @dynamic_field.company == current_user.company
        @dynamic_field.destroy

        if !@dynamic_field.destroy
            render 'error'
        end

        Activity.add(self.current_user, Activity::DYNAMIC_FIELD_DESTROYED, @dynamic_field, @dynamic_field.name)

    end

end
