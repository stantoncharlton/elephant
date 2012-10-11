class Document < ActiveRecord::Base
    attr_accessible :category,
                    :name,
                    :status,
                    :template,
                    :url


    validates :name, presence: true, length: {maximum: 50}
    validates :category, presence: true, length: {maximum: 50}

    belongs_to :job_template
    belongs_to :job

    before_create :default_name


    def default_name
        self.name ||= File.basename(url, '.*').titleize if url
    end


    def self.from_job_template(job_template)
        where("job_template_id = :job_template_id", job_template_id: job_template.id)
    end

    def self.from_job(job)
        where("job_id = :job_id", job_id: job.id)
    end

end
