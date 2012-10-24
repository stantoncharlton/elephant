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

    has_many :job_memberships, foreign_key: "job_id"
    has_many :users, through: :job_memberships, source: :user


    def add_user!(user)
        membership = job_memberships.new
        membership.user = user
        membership.job = self
        membership.save
    end

    def remove_user(user)
        job_memberships.find_by_user_id(user.id).destroy
    end

end
