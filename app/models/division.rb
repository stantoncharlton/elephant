class Division < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
    validates_presence_of :company

    belongs_to :company

    has_many :segments, dependent: :destroy, order: "name ASC"
    has_many :secondary_tools, dependent: :destroy, class_name: "Tool", order: "name ASC"

    searchable do
        text :name, :as => :code_textp
        integer :company_id
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

    def jobs
        Job.where("jobs.company_id = ?", self.company_id).where("divisions.id = ?", self.id).joins(job_template: {product_line: {segment: :division}})
    end

    def active_jobs
        Job.where("jobs.company_id = ?", self.company_id).where(:status => Job::ACTIVE).where("divisions.id = ?", self.id).includes(job_template: {product_line: {segment: :division}})
    end

    def self.from_company_for_user(division, options, user, company)
        Sunspot.search(Job) do
            with(:division_id, division.id)
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
        Sunspot.search(Division, Segment, ProductLine, JobTemplate) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            #order_by :name, :asc
            paginate :page => options[:page]
        end
    end
end
