class District < ActiveRecord::Base
    attr_accessible :name,
                    :location,
                    :region,
                    :address_line_1,
                    :address_line_2,
                    :phone_number,
                    :postal_code,
                    :support_email

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false
    validates :company, presence: true
    validates :country, presence: true

    belongs_to :company
    belongs_to :country
    belongs_to :state

    has_many :fields


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end



end
