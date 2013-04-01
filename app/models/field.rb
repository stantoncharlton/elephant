class Field < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :district_id
    validates :company, presence: true
    validates :district, presence: true

    belongs_to :company
    belongs_to :district

    has_many :wells, order: "name ASC"


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def self.from_company_for_user(field, options, user, company)
        Sunspot.search(Job) do
            with(:field_id, field.id)
            any_of do
                with(:job_membership, user.id)
                if user.role.limit_to_district?
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
