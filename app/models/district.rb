class District < ActiveRecord::Base
    attr_accessible :name,
                    :location

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false

    belongs_to :company
    belongs_to :country
    belongs_to :state

    has_many :fields


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end



end
