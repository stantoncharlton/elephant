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
        @dynamic_field.job_template_id = job_template_id

        if !@dynamic_field.save
            render 'error'
        end
    end

    def update
        @dynamic_field = DynamicField.find(params[:id])

        # todo
    end


    def destroy
        @dynamic_field = DynamicField.find(params[:id])
        @dynamic_field.destroy

        if !@dynamic_field.destroy
            render 'error'
        end
    end

end
