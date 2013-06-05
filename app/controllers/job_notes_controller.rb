class JobNotesController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :destroy]


    def new
        @job_note = JobNote.new
    end

    def create
        job_id = params[:job_note][:job_id]
        params[:job_note].delete(:job_id)

        assign_to_id = params[:job_note][:assign_to_id]
        params[:job_note].delete(:assign_to_id)

        @job_note = JobNote.new(params[:job_note])
        @job_note.company = current_user.company
        @job_note.user = current_user
        @job_note.user_name = current_user.name
        @job_note.job = Job.find_by_id(job_id)
        @job_note.assign_to = User.find_by_id(assign_to_id)

        if @job_note.save
            @job_note.delay.create_job_note self.current_user
        end
    end

    def destroy
        @job_note = JobNote.find(params[:id])
        not_found unless @job_note.company == current_user.company

        #Activity.add(self.current_user, Activity::CLIENT_DESTROYED, @client, @client.name)
        @job_note.destroy
    end



end
