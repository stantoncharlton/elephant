class JobNotesController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :destroy]


    def new
        @job_note = JobNote.new
    end

    def create
        job_id = params[:job_note][:job_id]
        params[:job_note].delete(:job_id)

        issue_id = params[:job_note][:issue_id]
        params[:job_note].delete(:issue_id)

        assign_to_id = params[:job_note][:assign_to_id]
        params[:job_note].delete(:assign_to_id)

        @job_note = JobNote.new(params[:job_note])
        @job_note.company = current_user.company
        @job_note.user = current_user
        @job_note.user_name = current_user.name
        if !job_id.blank?
            @job_note.job = Job.find_by_id(job_id)
        end
        if !issue_id.blank?
            @job_note.issue = Issue.find_by_id(issue_id)
            @job_note.note_type = JobNote::NOTE
        end
        @job_note.assign_to = User.find_by_id(assign_to_id)

        if @job_note.save
            if @job_note.issue.nil?
                @job_note.delay.create_job_note self.current_user
            end
        end
    end

    def destroy
        @job_note = JobNote.find(params[:id])
        not_found unless @job_note.company == current_user.company

        #Activity.add(self.current_user, Activity::CLIENT_DESTROYED, @client, @client.name)
        @job_note.destroy
    end


end
