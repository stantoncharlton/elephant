class Company < ActiveRecord::Base
    attr_accessible :name,
                    :address_line_1,
                    :address_line_2,
                    :postal_code,
                    :state,
                    :country,
                    :logo,
                    :logo_large,
                    :phone_number,
                    :support_email,
                    :website,
                    :vpn_range,
                    :test_company

    validates :name, presence: true, uniqueness: true, length: {maximum: 50}

    has_many :users, dependent: :destroy, order: "name ASC"
    has_many :roles, dependent: :destroy, class_name: "UserRole"
    has_many :districts, dependent: :destroy, order: "name ASC"
    has_many :clients, dependent: :destroy, order: "name ASC"
    has_many :fields, dependent: :destroy, order: "name ASC"
    has_many :wells, dependent: :destroy, order: "name ASC"
    has_many :divisions, dependent: :destroy, order: "name ASC"
    has_many :segments, dependent: :destroy, order: "name ASC"
    has_many :product_lines, dependent: :destroy, order: "name ASC"
    has_many :job_templates, dependent: :destroy, order: "name ASC"
    has_many :jobs, dependent: :destroy, order: "jobs.created_at ASC"
    has_many :tools, dependent: :destroy
    has_many :failures, dependent: :destroy
    has_many :dynamic_fields, dependent: :destroy
    has_many :documents, dependent: :destroy
    has_many :conversations, dependent: :destroy
    has_many :alerts, dependent: :destroy
    has_many :activities, dependent: :destroy

    belongs_to :admin


    def active_jobs
        self.jobs.where(:status => Job::ACTIVE)
    end

end
