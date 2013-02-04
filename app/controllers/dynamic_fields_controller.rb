class DynamicFieldsController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :destroy]
    before_filter :signed_in_user, only: [:show, :update]

    respond_to :js

    def show
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @dynamic_field.company == current_user.company

        respond_to do |format|
            format.js {
                if params[:reorder].present?
                    if params[:reorder] == "-1"
                        if @dynamic_field.order > 0
                            DynamicField.transaction do
                                @dynamic_field.order -= 1
                                @dynamic_field.save

                                collection = @dynamic_field.job_template.dynamic_fields.sort_by { |e| e.order || 0 }
                                collection.each do |field|
                                    if field != @dynamic_field and (field.order || 0) == @dynamic_field.order
                                        field.order = (field.order || 0) + 1
                                        field.save
                                    end
                                end
                            end

                            @move_up = true

                            render 'dynamic_fields/reorder'
                        else
                            render :nothing => true, :status => :ok
                        end
                    end
                end
            }
        end
    end

    def new
        @dynamic_field = DynamicField.new(params[:dynamic_field])
    end

    def create

        job_template_id = params[:dynamic_field][:job_template_id]
        params[:dynamic_field].delete(:job_template_id)

        @dynamic_field = DynamicField.new(params[:dynamic_field])
        @dynamic_field.company = current_user.company
        @dynamic_field.job_template = JobTemplate.find_by_id(job_template_id)
        @dynamic_field.order = @dynamic_field.job_template.dynamic_fields.count

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
            if params[:value].present?
                @dynamic_field.value = params[:value]
                @dynamic_field.save
            elsif params[:unit].present?
                @dynamic_field.value_type = params[:unit]
                @dynamic_field.save
            end

            Activity.add(current_user, Activity::DATA_EDITED, @dynamic_field, @dynamic_field.name, @dynamic_field.job)
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
