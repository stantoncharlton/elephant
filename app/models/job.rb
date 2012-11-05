class Job < ActiveRecord::Base
    attr_accessible :client_contact_name,
                    :start_date,
                    :end_date



    validates_presence_of :company_id
    validates_presence_of :client_id
    validates_presence_of :district_id
    validates_presence_of :field_id
    validates_presence_of :well_id
    validates_presence_of :job_template_id

    belongs_to :company
    belongs_to :client
    belongs_to :district
    belongs_to :field
    belongs_to :well
    belongs_to :job_template

    has_many :dynamic_fields
    has_many :documents

    has_many :job_memberships, foreign_key: "job_id"
    has_many :participants, through: :job_memberships, source: :user

    has_one :district_manager, class_name: "User", foreign_key: "id"
    has_one :sales_engineer, class_name: "User", foreign_key: "id"


    searchable do
        text :field_name do
            field.name
        end
        text :well_name do
            well.name
        end

        time :created_at
        time :updated_at
    end


    def add_user!(user)
        membership = job_memberships.new
        membership.user = user
        membership.job = self
        membership.save
    end

    def remove_user(user)
        job_memberships.find_by_user_id(user.id).destroy
    end

    def self.from_user(user)
        where("jobs.company_id = :company_id", company_id: user.company.id).order("jobs.created_at DESC")
    end

    def self.from_company(company)
        where("jobs.company_id = :company_id", company_id: company.id).order("jobs.created_at DESC")
    end

    def self.from_field(field)
        where("jobs.field_id = :field_id", field_id: field.id).order("jobs.created_at DESC")
    end


end
