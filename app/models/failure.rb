class Failure < ActiveRecord::Base
    attr_accessible :text,
                    :reference,
                    :template

    validates :text, presence: true, length: {maximum: 100}, :if => :template?
    validates_uniqueness_of :text, :case_sensitive => false, :scope => [:product_line_id], :if => :template?
    validates_presence_of :company
    validates_presence_of :product_line_id, :if =>  :template?

    belongs_to :failure_master_template, class_name: "Failure"
    belongs_to :company
    belongs_to :product_line
    belongs_to :job_template
    belongs_to :job

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id)
    end

end
