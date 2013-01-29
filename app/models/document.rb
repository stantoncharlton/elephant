class Document < ActiveRecord::Base
    attr_accessible :category,
                    :name,
                    :status,
                    :document_type,
                    :template,
                    :url,
                    :read_only,
                    :order


    validates :name, presence: true, length: {maximum: 50}
    validates :category, presence: true, length: {maximum: 50}
    validates :company, presence: true

    belongs_to :job_template, :conditions => ['documents.template = ?', true]
    belongs_to :document_template, class_name: "Document"
    belongs_to :job
    belongs_to :company

    belongs_to :user, class_name: "User"

    before_create :default_name


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

end
