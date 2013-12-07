class IssuesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :create, :update]

    def index
        @issues = Issue.where(:company_id => current_user.company).order("issues.status ASC, issues.created_at DESC")
        if current_user.district.present?
            @issues = @issues.includes(:job).where("jobs.district_id IN (SELECT id FROM districts where master_district_id = :district_id)", district_id: current_user.district.master_district_id)
        end

        @issues = @issues.paginate(page: params[:page], limit: 20)
        @failures_current_year = Failure.where(:company_id => current_user.company_id).where(:template => false).where("failures.job_id IS NOT NULL").where("failures.created_at >= '#{ Time.now.year }/1/1'").select("date_trunc('month', failures.created_at) as DATE").group("date_trunc('month', failures.created_at)").count("failures.created_at").map { |k, v| {Date.strptime(k).month => v} }.reduce(:merge)
    end

    def show
        @issue = Issue.find_by_id(params[:id])
        not_found unless @issue.present? && @issue.company == current_user.company
    end

    def create

        failure_id = params[:issue][:failure_id]
        params[:issue].delete(:failure_id)

        @failure = Failure.find_by_id(failure_id)

        job_id = params[:issue][:job_id]
        params[:issue].delete(:job_id)

        @job = Job.find_by_id(job_id)
        not_found unless @job.present? && @job.company == current_user.company

        Issue.transaction do
            @issue = Issue.new(status: Issue::OPEN)
            @issue.failure = @failure
            @issue.company = current_user.company
            @issue.job = @job
            @issue.failure_at = Time.strptime("#{params[:date]} #{params[:hour]}:#{params[:minute]}:00 #{params[:meridian]}", '%m/%d/%Y %I:%M:%S %p').in_time_zone(Time.zone)

            if !params[:part_membership_id].blank?
                @part_membership = PartMembership.find(params[:part_membership_id])
                if @part_membership.present?
                    if @part_membership.part.present?
                        @issue.part = @part_membership.part
                    end
                    @issue.part_serial_number = @part_membership.serial_number
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
        end

        #job_failure.delay.add_alert(current_user, @job)

        render 'failures/update_list'
    end

    def update
        @issue = Issue.find_by_id(params[:id])
        not_found unless @issue.company == current_user.company

        if params[:closed] == "true"
            @issue.update_attribute(:status, Issue::CLOSED)
        end
    end

end
