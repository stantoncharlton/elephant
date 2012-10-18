class ProductLine < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false

    belongs_to :company

    has_many :job_templates, dependent: :destroy


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

end