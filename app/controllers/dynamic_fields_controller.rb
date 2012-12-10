class DynamicFieldsController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :destroy]
    before_filter :signed_in_user, only: [:update]

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

    def edit
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @dynamic_field.company == current_user.company
    end

    def update
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @dynamic_field.company == current_user.company

        if @dynamic_field.template?
            @dynamic_field.update_attributes(params[:dynamic_field])
        else
            @dynamic_field.value = params[:value]
            @dynamic_field.save
        end
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
