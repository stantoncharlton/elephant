class JobTemplate < ActiveRecord::Base
    attr_accessible :name,
                    :dynamic_fields_attributes,
                    :documents_attributes,
                    :description


    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, :scope => :product_line_id
    validates :company, presence: true
    validates :product_line, presence: true

    belongs_to :company
    belongs_to :product_line

    has_many :dynamic_fields, :conditions => ['dynamic_fields.template = ?', true]
    accepts_nested_attributes_for :dynamic_fields, :allow_destroy => true

    has_many :documents, :conditions => ['documents.template = ?', true]
    accepts_nested_attributes_for :documents, :allow_destroy => true


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

end
