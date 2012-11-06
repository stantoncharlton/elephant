class JobNotesController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :destroy]



    def new
        @job_note = JobNote.new
    end

    def create
        job_id = params[:job_note][:job_id]
        params[:job_note].delete(:job_id)

        @job_note = JobNote.new(params[:job_note])
        @job_note.company = current_user.company
        @job_note.user = current_user
        @job_note.job = Job.find_by_id(job_id)

        @job_note.save

            #Activity.add(self.current_user, Activity::CLIENT_CREATED, @client, @client.name)
    end

    def destroy
        @job_note = JobNote.find(params[:id])
        not_found unless @job_note.company == current_user.company

        #Activity.add(self.current_user, Activity::CLIENT_DESTROYED, @client, @client.name)
        @job_note.destroy
    end

end
