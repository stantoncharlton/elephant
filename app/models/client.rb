class Client < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false
    validates :company, presence: true

    belongs_to :company


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end


end
