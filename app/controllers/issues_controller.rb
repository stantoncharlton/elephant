class IssuesController < ApplicationController
    before_filter :signed_in_user, only: [:create, :edit, :update]
    before_filter :signed_in_user_not_field, only: [:index, :show, :destroy]

    def index
        @issues = Issue.where(:company_id => current_user.company).order("issues.status ASC, issues.created_at DESC")
        if current_user.district.present?
            @issues = @issues.includes(:job).where("jobs.district_id IN (SELECT id FROM districts where master_district_id = :district_id)", district_id: current_user.district.master_district_id)
        end

        @issues = @issues.paginate(page: params[:page], limit: 20)
    end

    def show
        @issue = Issue.find_by_id(params[:id])
        not_found unless @issue.present?
    end

    def create

        failure_id = params[:issue][:failure_id]
        params[:issue].delete(:failure_id)

        job_id = params[:issue][:job_id]
        params[:issue].delete(:job_id)

        @job = Job.find_by_id(job_id)
        not_found unless @job.present? && @job.company == current_user.company

        Issue.transaction do
            @issue = Issue.new(status: Issue::OPEN)
            if !failure_id.blank?
                @failure = Failure.find_by_id(failure_id)
                @issue.failure = @failure
            end
            @issue.company = current_user.company
            @issue.job = @job

            date = Date.strptime("#{params[:date]}", '%m/%d/%Y')
            @issue.failure_at = Time.zone.parse("#{date.year}-#{date.month}-#{date.day} #{params[:entry_time]}")

            if !params[:part_membership_id].blank?
                @part_membership = PartMembership.find_by_id(params[:part_membership_id])
                if @part_membership.present?
                    if @part_membership.part.present?
                        @issue.part = @part_membership.part
                    end
                    @issue.part_serial_number = @part_membership.serial_number
                end
            end

            if !params[:responsible_by_id].blank?
                @user = User.find_by_id(params[:responsible_by_id])
                if @user.present?
                    @issue.responsible_by = @user
                    @issue.responsible_by_name = @user.name
                end
            end

            @issue.save

            if params[:description]
                @note = JobNote.new
                @note.user = current_user
                @note.user_name = current_user.name
                @note.note_type = JobNote::NOTE
                @note.text = params[:description]
                @note.company = current_user.company
                @note.issue = @issue
                @note.save
            end

            document = Document.new
            document.name = "Issue Report"
            document.category = Document::ISSUES
            document.document_type = Document::DOCUMENT
            document.read_only = false
            document.ordering = 0
            document.template = false
            document.owner = @issue
            document.company = current_user.company
            document.save

            @issue.delay.update_failure_count
            Activity.delay.add(current_user, Activity::ISSUE_OPENED, @issue, nil, @issue.job)
        end

        #job_failure.delay.add_alert(current_user, @job)

        render 'failures/update_list'
    end

    def edit
        @issue = Issue.find_by_id(params[:id])
        not_found unless @issue.present?
    end

    def update
        @issue = Issue.find_by_id(params[:id])
        not_found unless @issue.present?

        @update_object = false

        if params[:update_field].present? && params[:update_field] == "true" &&
                params[:field].present? && params[:value].present?
            case params[:field]
                when "failure_id"
                    @issue.failure = Failure.find_by_id(params[:value])
                    @issue.save
                when "accountable"
                    @issue.accountable = params[:value] == "true"
                    @issue.save
                when "part_membership_id"
                    if params[:value] == "0"
                        @issue.part = nil
                        @issue.save
                    else
                        part_membership = PartMembership.find_by_id(params[:value])
                        if part_membership.present?
                            if part_membership.part.present?
                                @issue.part = part_membership.part
                            else
                                @issue.part = nil
                            end
                            @issue.part_serial_number = part_membership.serial_number
                            @issue.save
                        end
                    end
                when "responsible_by_id"
                    user = User.find_by_id(params[:value])
                    if user.present?
                        @issue.responsible_by = user
                        @issue.responsible_by_name = user.name
                        @issue.save
                    end
            end
        elsif params[:closed] == "true"
            if @issue.failure.present?
                @issue.update_attribute(:status, Issue::CLOSED)
                Activity.delay.add(current_user, Activity::ISSUE_CLOSED, @issue, @issue.failure.text, @issue.job)
            else
                @issue.errors.add(:failure_id, " type needs to be set")
            end
        elsif params[:update_object].present? && params[:update_object] == "true"
            @update_object = true
            date = Date.strptime("#{params[:date]}", '%m/%d/%Y')
            @issue.failure_at = Time.zone.parse("#{date.year}-#{date.month}-#{date.day} #{params[:entry_time]}")
            @issue.save

            if params[:description] && !params[:description].blank?
                @note = JobNote.new
                @note.user = current_user
                @note.user_name = current_user.name
                @note.note_type = JobNote::NOTE
                @note.text = params[:description]
                @note.company = current_user.company
                @note.issue = @issue
                @note.save
            end
        end
    end

    def destroy
        @issue = Issue.find_by_id(params[:id])
        @issue.destroy
        redirect_to issues_path
    end

end
