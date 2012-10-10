class JobTemplate < ActiveRecord::Base
    attr_accessible :name, :dynamic_fields_attributes


    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false

    belongs_to :company
    belongs_to :product_line

    has_many :dynamic_fields
    accepts_nested_attributes_for :dynamic_fields, :allow_destroy => true


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end


end
