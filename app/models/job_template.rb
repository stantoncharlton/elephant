class JobTemplate < ActiveRecord::Base
    attr_accessible :name,
                    :dynamic_fields_attributes,
                    :documents_attributes,
                    :description


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


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

    def self.from_company_for_user(job_template, options, user, company)
        Sunspot.search(Job) do
            with(:job_template_id, job_template.id)
            any_of do
                with(:job_membership, user.id)
                if user.role.district_read?
                    with(:district_id, user.district.id)
                end
                if user.role.product_line_read? and !user.product_line.nil?
                    with(:product_line_id, user.product_line.id)
                end
            end
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end

    def notices_documents
        self.documents.select { |document| document.category == Document::NOTICES }
    end

    def pre_job_documents
        self.documents.select { |document| document.category == Document::PRE_JOB }
    end

    def post_job_documents
        self.documents.select { |document| document.category == Document::POST_JOB }
    end

end
