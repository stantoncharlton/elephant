class ProductLine < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :segment_id
    validates_presence_of :company
    validates_presence_of :segment

    belongs_to :segment
    belongs_to :company

    has_many :job_templates, dependent: :destroy, order: "name ASC"


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

end
