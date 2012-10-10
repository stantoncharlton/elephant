class Job < ActiveRecord::Base
    attr_accessible :client_contact_name,
                    :district_manager_id,
                    :start_date,
                    :end_date,
                    :sales_engineer_id



    validates_presence_of :company_id
    validates_presence_of :client_id
    validates_presence_of :district_id
    validates_presence_of :field_id
    validates_presence_of :well_id
    validates_presence_of :job_template_id

    belongs_to :company
    has_one :client, through: :company
    has_one :district, through: :company
    has_one :field, through: :company
    has_one :job_template, through: :company

    belongs_to :well

    has_many :dynamic_fields
    has_many :documents
end
