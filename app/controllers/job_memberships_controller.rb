class JobMembershipsController < ApplicationController
    before_filter :signed_in_user, only: [:create, :destroy]

    def create
        job_id = params[:job_membership][:job_id]
        params[:job_membership].delete(:job_id)

        user_id = params[:job_membership][:user_id]
        params[:job_membership].delete(:user_id)

        @job = Job.find_by_id(job_id)
        not_found unless @job.company == current_user.company

        @user = User.find_by_id(user_id)

        @job_membership = JobMembership.new
        @job_membership.user = @user
        @job_membership.job = @job
        @job_membership.save

        Activity.add(self.current_user, Activity::JOB_MEMBER_ADDED, @job_membership, nil, @job)


    end

    def destroy
        @job_membership = JobMembership.find_by_id(params[:id])
        not_found unless @job_membership.user.company == current_user.company

        @job_membership.destroy
    end
end
