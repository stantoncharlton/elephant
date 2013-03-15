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

    def self.from_company_for_user(division, options, user, company)
        Sunspot.search(Job) do
            with(:division_id, division.id)
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

    def self.search(options, company)
        Sunspot.search(User) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page]
        end
    end
end
