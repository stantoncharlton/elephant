class Company < ActiveRecord::Base
    attr_accessible :name,
                    :address_line_1,
                    :address_line_2,
                    :postal_code,
                    :city,
                    :state,
                    :country,
                    :logo,
                    :logo_large,
                    :phone_number,
                    :support_email,
                    :website,
                    :vpn_range,
                    :test_company,
                    :inventory_active,
                    :minimum_work_day,
                    :work_day_type,
                    :payroll_schedule,
                    :operator_number,
                    :railroad_signer,
                    :railroad_signer_title

    after_commit :flush_cache

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
    has_many :warehouses, dependent: :destroy
    has_many :parts, dependent: :destroy
    has_many :part_redresses, dependent: :destroy
    has_many :drilling_logs, dependent: :destroy
    has_many :surveys, dependent: :destroy
    has_many :bhas, dependent: :destroy
    has_many :issues, dependent: :destroy

    belongs_to :admin


    HOURLY_WORK_DAY = 1
    DAILY_WORK_DAY = 2

    PAYROLL_NONE = 0
    PAYROLL_BIMONTHLY_EVEN = 1


    def active_jobs
        self.jobs.where("jobs.status >= 1 AND jobs.status < 50")
    end

    def self.cached_find(id)
        Rails.cache.fetch([name, id], expires_in: 30.days) { find(id) }
    end

    def flush_cache
        Rails.cache.delete([self.class.name, id])
    end

end
