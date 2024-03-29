class Tool < ActiveRecord::Base
    attr_accessible :name,
                    :description

    validates :name, presence: true, length: {maximum: 100}
    validates :description, length: {maximum: 255}
    validates_uniqueness_of :name, :case_sensitive => false, :scope => [:division_id, :product_line_id]
    validates_presence_of :company

    belongs_to :company
    belongs_to :division
    belongs_to :product_line

    has_many :primary_tools, dependent: :destroy
    has_many :secondary_tools, dependent: :destroy

    acts_as_tenant(:company)


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end
end
