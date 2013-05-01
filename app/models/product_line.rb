class ProductLine < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :segment_id
    validates_presence_of :company
    validates_presence_of :segment

    belongs_to :segment
    belongs_to :company

    has_many :job_templates, dependent: :destroy, order: "name ASC"
    has_many :primary_tools, dependent: :destroy, class_name: "Tool", order: "name ASC"

    has_many :failures, dependent: :destroy, order: "text ASC"

    searchable do
        text :name, :as => :code_textp
        integer :company_id
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

    def jobs
        self.company.jobs.joins(job_template: :product_line).where("product_lines.id = ?", self.id)
    end

    def active_jobs
        self.company.jobs.where(:status => Job::ACTIVE).joins(job_template: :product_line).where("product_lines.id = ?", self.id)
    end

    def self.from_company_for_user(product_line, options, user, company)
        Sunspot.search(Job) do
            with(:product_line_id, product_line.id)
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

end
