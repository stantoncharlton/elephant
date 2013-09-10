class JobTemplate < ActiveRecord::Base
    attr_accessible :name,
                    :dynamic_fields_attributes,
                    :documents_attributes,
                    :description,
                    :track_accessories

    acts_as_tenant(:company)


    validates :name, presence: true, length: {maximum: 100}
    validates_uniqueness_of :name, :case_sensitive => false, :scope => :product_line_id
    validates :company, presence: true
    validates :product_line, presence: true

    belongs_to :company
    belongs_to :product_line

    has_many :dynamic_fields, order: "ordering ASC", :conditions => ['dynamic_fields.template = ?', true]
    accepts_nested_attributes_for :dynamic_fields, :allow_destroy => true

    has_many :documents, order: "ordering ASC", :conditions => ['documents.template = ?', true]
    accepts_nested_attributes_for :documents, :allow_destroy => true

    has_many :primary_tools
    has_many :post_job_report_documents, order: "ordering ASC", :dependent => :destroy
    has_many :failures, dependent: :destroy, order: "text ASC"

    searchable do
        text :name, :as => :code_textp
        integer :company_id
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

    def jobs
        self.company.jobs.joins(:job_template).where("job_templates.id = ?", self.id)
    end

    def active_jobs
        Job.where("jobs.company_id = ?", self.company_id).where(:status => Job::ACTIVE).joins(:job_template).where("job_templates.id = ?", self.id)
    end

    def self.from_company_for_user(job_template, options, user, company)
        Sunspot.search(Job) do
            with(:job_template_id, job_template.id)
            any_of do
                if user.role.limit_to_assigned_jobs?
                    with(:job_membership, user.id)
                elsif user.role.limit_to_district?
                    with(:district_id, user.district.id)
                elsif user.role.limit_to_product_line? && !user.product_line.nil?
                    with(:product_line_id, user.product_line.id)
                end
            end
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end

    def self.search(options, company)
        Sunspot.search(JobTemplate) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            #order_by :name, :asc
            paginate :page => options[:page]
        end
    end

    def notices_documents
        self.documents.where(:category => Document::NOTICES)
    end

    def pre_job_documents
        self.documents.where(:category => Document::PRE_JOB)
    end

    def on_job_documents
        self.documents.where(:category => Document::ON_JOB)
    end

    def post_job_documents
        self.documents.where(:category => Document::POST_JOB)
    end

    def post_job_report_document_options
        collection = []

        collection << ["", -1]
        collection << ["(+) New Document exclusively for report", 0]
        collection << ["(+) Job Custom Data", -10]
        collection << ["", -1]

        collection << [Document::NOTICES + " (" + notices_documents.count.to_s + ") ------------------------", -1]
        notices_documents.each do |document|
            collection << [document.name, document.id]
        end

        collection << ["", -1]
        collection << [Document::PRE_JOB + " (" + pre_job_documents.count.to_s + ") ------------------------", -1]
        pre_job_documents.each do |document|
            collection << [document.name, document.id]
        end

        collection << ["", -1]
        collection << [Document::ON_JOB + " (" + on_job_documents.count.to_s + ") ------------------------", -1]
        on_job_documents.each do |document|
            collection << [document.name, document.id]
        end

        collection << ["", -1]
        collection << [Document::POST_JOB + " (" + post_job_documents.count.to_s + ") ------------------------", -1]
        post_job_documents.each do |document|
            collection << [document.name, document.id]
        end

        collection
    end

end
