class JobProcessController < ApplicationController
    before_filter :signed_in_user, only: [:show]

    def show

        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        # Check all data before review
        @job.documents.each do |document|
            if document.url.nil? || document.url.empty?
                render :nothing => true, :status => :ok
            end
        end

        @job.dynamic_fields.each do |df|
            if df.value.nil? || df.value.empty?
                render :nothing => true, :status => :ok
            end
        end

        supervisor = nil
        creator = nil


        # Check Role for supervisor
        @job.job_memberships.each do |jm|
            puts jm.user.name
            if jm.job_role_id == 2
                supervisor = jm.user
            elsif jm.job_role_id == 6
                creator = jm.user
            end
        end

        if !supervisor.nil? && !current_user?(supervisor)
            puts "emailing supervisor............."
           # Send supervisor email
            JobProcessMailer.pre_job_data_complete(supervisor, @job).deliver
        end

        if supervisor.nil? && !creator.nil? && !current_user?(creator)
            puts "emailing creator............."

            # Send creator email
            JobProcessMailer.pre_job_data_complete(creator, @job).deliver
        end

    end

end
