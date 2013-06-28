class Document < ActiveRecord::Base
    attr_accessible :category,
                    :name,
                    :status,
                    :document_type,
                    :template,
                    :url,
                    :read_only,
                    :ordering,
                    :user_name


    validates :name, presence: true, length: {maximum: 50}
    validates :category, presence: true, length: {maximum: 50}
    validates :company, presence: true

    belongs_to :job_template #, :conditions => ['documents.template = ?', true]
    belongs_to :document_template, class_name: "Document"
    belongs_to :job
    belongs_to :company

    belongs_to :user, class_name: "User"

    before_create :default_name

    has_one :post_job_report_document, :dependent => :destroy
    has_many :document_shares, dependent: :destroy


    NOTICES = "Notices"
    PRE_JOB = "Pre-Job"
    POST_JOB = "Post-Job"
    POST_JOB_REPORT_PART = "Post Job Report Part"
    POST_JOB_REPORT = "Post Job Report"

    def default_name
        self.name ||= File.basename(url, '.*').titleize if url
    end

    def file_name
        File.basename(url).titleize if url
    end

    def document_type_string
        if self.document_type == 0
            "Document"
        else
            "Checklist"
        end
    end

    def full_url
        if !self.url.blank?
            s3 = AWS::S3.new
            obj = s3.buckets['elephant-docs'].objects[self.url].url_for(:read)
            obj.to_s
        else
            ""
        end
    end


    def self.from_job_template(job_template)
        where("job_template_id = :job_template_id", job_template_id: job_template.id)
    end

    def self.from_job(job)
        where("job_id = :job_id", job_id: job.id)
    end

    def document_collection
        collection = []
        if self.template? and !self.job_template.nil?
            case self.category
                when Document::NOTICES
                    collection = self.job_template.notices_documents
                when Document::PRE_JOB
                    collection = self.job_template.pre_job_documents
                when Document::POST_JOB
                    collection = self.job_template.post_job_documents
            end
        elsif !self.job.nil?
            case self.category
                when Document::NOTICES
                    collection = self.job.notices_documents
                when Document::PRE_JOB
                    collection = self.job.pre_job_documents
                when Document::POST_JOB
                    collection = self.job.post_job_documents
            end
        end

        if collection.nil?
            collection = []
        end

        collection
    end

    def delete_document
        if !self.url.blank?
            s3 = AWS::S3.new
            obj = s3.buckets['elephant-docs'].objects[self.url].delete
            obj.to_s
        end
    end

    def upload_info
        sts = AWS::STS.new()
        policy = AWS::STS::Policy.new
        policy.allow(
                :actions => ["s3:PutObject"],
                :resources => "arn:aws:s3:::elephant-docs/*")

        session = sts.new_federated_session(
                'User_' + UserObserver.current_user.id.to_s,
                :policy => policy,
                :duration => 2*60*60)

        record = Struct.new(:uploadKey, :accessKeyId, :secretAccessKey, :sessionToken) do
            def to_xml(options = {})
                "<uploadKey>docs/#{uploadKey}</uploadKey><accessKeyId>#{accessKeyId}</accessKeyId><secretAccessKey>#{secretAccessKey}</secretAccessKey><sessionToken>#{sessionToken}</sessionToken>"
            end
        end

        record.new(SecureRandom.hex,
                   session.credentials[:access_key_id],
                   session.credentials[:secret_access_key],
                   session.credentials[:session_token]).to_xml
    end


    def add_notices_on_active_jobs
        self.company.jobs.where("jobs.job_template_id = ?", self.job_template_id).where("jobs.status = ?", Job::ACTIVE).each do |job|
            job_document = Document.new
            job_document.category = self.category
            job_document.name = self.name
            job_document.status = self.status
            job_document.document_type = self.document_type
            job_document.read_only = self.read_only
            job_document.ordering = self.ordering
            job_document.template = false
            job_document.url = nil
            job_document.document_template = self
            job_document.job_template = job.job_template
            job_document.job = job
            job_document.company = self.company
            job_document.save

            job.unique_participants.each do |participant|
                UserMailer.new_notice_on_job(participant, job, self).deliver
            end
        end
    end

end
