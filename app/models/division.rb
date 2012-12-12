class Division < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false
    validates_presence_of :company

    belongs_to :company

    has_many :segments, dependent: :destroy, order: "name ASC"


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end
end
