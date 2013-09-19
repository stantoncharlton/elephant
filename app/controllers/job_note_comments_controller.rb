class JobNoteCommentsController < ApplicationController
    before_filter :signed_in_user, only: [:create, :destroy]


    def create
        job_note_id = params[:job_note_comment][:job_note_id]
        params[:job_note_comment].delete(:job_note_id)

        @job_note = JobNote.find_by_id(job_note_id)
        not_found unless @job_note.company == current_user.company

        @comment = JobNoteComment.new(params[:job_note_comment])
        @comment.job_note = @job_note
        @comment.user = current_user
        @comment.user_name = current_user.name
        @comment.job = @job_note.job
        @comment.company = current_user.company
        @comment.save

        #Activity.add(self.current_user, Activity::JOB_MEMBER_ADDED, @job_membership, nil, @job)

        #Alert.add(@user, Alert::ADDED_TO_JOB, @job, current_user, @job)

    end

    def destroy
        @comment = JobNoteComment.find_by_id(params[:id])
        not_found unless @comment.company == current_user.company

        @comment.destroy
    end

end
