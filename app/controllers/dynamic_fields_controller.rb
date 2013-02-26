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

        value = params[:dynamic_field][:value]
        params[:dynamic_field].delete(:value)

        @dynamic_field = DynamicField.new(params[:dynamic_field])
        @dynamic_field.company = current_user.company
        @dynamic_field.job_template = JobTemplate.find_by_id(job_template_id)
        @dynamic_field.order = @dynamic_field.job_template.dynamic_fields.count

        if !value.blank?
            @dynamic_field.predefined = true
            @dynamic_field.value = value
        else
            @dynamic_field.predefined = false
        end

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

        @is_valid = true

        if @dynamic_field.template?
            DynamicField.transaction do
                @dynamic_field.update_attribute(:name, params[:dynamic_field][:name])
                @dynamic_field.update_attribute(:value_type, params[:dynamic_field][:value_type])
                @dynamic_field.update_attribute(:priority, params[:dynamic_field][:priority])
                if !params[:dynamic_field][:value].blank?
                    @dynamic_field.update_attribute(:value, params[:dynamic_field][:value])
                    @dynamic_field.update_attribute(:predefined, true)
                else
                    @dynamic_field.update_attribute(:predefined, false)
                end
            end
        else
            if params[:value].present?
                if @dynamic_field.value_type != DynamicField::STRING
                    @is_valid = params[:value].match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil
                end
                @dynamic_field.value = params[:value]
                @dynamic_field.save
            elsif params[:unit].present?
                @dynamic_field.value_type = params[:unit]
                @dynamic_field.save
            end

            activity = @dynamic_field.job.activity.limit(1).last
            if activity != nil and (activity.created_at > 10.minutes.ago) and activity.activity_type == Activity::DATA_EDITED
                activity.metadata += ", " + @dynamic_field.name
                activity.save
            else
                Activity.add(current_user, Activity::DATA_EDITED, @dynamic_field, @dynamic_field.name, @dynamic_field.job)
            end
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
