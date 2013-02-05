class UserRole < ActiveRecord::Base
    attr_accessible :title,
                    :create_job,
                    :assign_users,
                    :district_read,
                    :district_modify,
                    :product_line_read,
                    :product_line_modify,
                    :global_read,
                    :global_modify,
                    :document_templates_modify

    validates :title, presence: true, length: {maximum: 50}, uniqueness: {case_sensitive: false, scope: :company_id}
    validates_presence_of :company


    belongs_to :company


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("title ASC")
    end
end
