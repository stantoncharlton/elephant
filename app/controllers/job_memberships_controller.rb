class JobMembershipsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new
        @job_membership = JobMembership.new
    end

    def create
        job_id = params[:job_membership][:job_id]
        params[:job_membership].delete(:job_id)

        user_id = params[:job_membership][:user_id]
        params[:job_membership].delete(:user_id)

        @job = Job.find_by_id(job_id)
        not_found unless @job.company == current_user.company

        @user = User.find_by_id(user_id)

        @job_membership = JobMembership.new(params[:job_membership])
        @job_membership.user = @user
        if @user.present?
            @job_membership.user_name = @user.name
        end
        @job_membership.job = @job
        @job_membership.company = @job.company
        if @job_membership.save

            if current_user.id != @user.id
                @user.delay.send_added_to_job_email(@job)
            end

            Activity.add(self.current_user, Activity::JOB_MEMBER_ADDED, @job_membership, @user.name, @job)

            Alert.add(@user, Alert::ADDED_TO_JOB, @job, current_user, @job)
        else
            #render template: 'layouts/error', locals: {title: "Problem Adding Member", object: @job_membership}
        end
    end

    def edit
        @job_membership = JobMembership.find_by_id(params[:id])
        not_found unless @job_membership.job.company == current_user.company
    end

    def update
        @job_membership = JobMembership.find_by_id(params[:id])
        not_found unless @job_membership.job.company == current_user.company

        if @job_membership.update_attributes(params[:job_membership])
            #Activity.add(self.current_user, Activity::PRODUCT_LINE_UPDATED, @product_line, @product_line.name)
        else
            render 'edit'
        end
    end

    def destroy
        @job_membership = JobMembership.find_by_id(params[:id])
        not_found unless @job_membership.job.company == current_user.company

        @job_membership.destroy
    end
end
