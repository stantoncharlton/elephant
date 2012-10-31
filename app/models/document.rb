class Document < ActiveRecord::Base
    attr_accessible :category,
                    :name,
                    :status,
                    :document_type,
                    :template,
                    :url


    validates :name, presence: true, length: {maximum: 50}
    validates :category, presence: true, length: {maximum: 50}

    belongs_to :job_template, :conditions => ['documents.template = ?', true]
    belongs_to :document_template, class_name: "Document"
    belongs_to :job
    belongs_to :company

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
        s3 = AWS::S3.new
        puts "sdfs"
        puts self.url
        obj = s3.buckets['elephant-docs'].objects[self.url].url_for(:read)
        obj.to_s;
    end


    def self.from_job_template(job_template)
        where("job_template_id = :job_template_id", job_template_id: job_template.id)
    end

    def self.from_job(job)
        where("job_id = :job_id", job_id: job.id)
    end

end
