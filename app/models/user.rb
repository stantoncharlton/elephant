class User < ActiveRecord::Base
    attr_accessible :email,
                    :name,
                    :time_zone,
                    :language,
                    :phone_number,
                    :location,
                    :password,
                    :password_confirmation,
                    :admin,
                    :accepted_tou,
                    :send_daily_activity,
                    :unverified_network,
                    :network_access_code,
                    :verified_networks

    has_secure_password


    before_save { |user| user.email = email.downcase }
    before_save :create_remember_token

    validates :name, presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
              length: {maximum: 50},
              format: {with: VALID_EMAIL_REGEX},
              uniqueness: {case_sensitive: false}
    validates :company, presence: true, unless: :is_elephant_admin?
    validates :role, presence: true, unless: :is_admin?
    validates :district, presence: true, unless: :is_admin?
    validates :password, presence: true, length: {minimum: 6}
    validates :password_confirmation, presence: true

    #validates_presence_of :district, unless: Proc.new { |ex| ex.admin == true }

    has_many :alerts, order: "created_at DESC"

    has_many :job_memberships, foreign_key: "user_id"
    has_many :jobs, through: :job_memberships, source: :job, order: "jobs.created_at DESC", uniq: true do
        def count(column_name = nil, opts = {})
            super(column_name || 'jobs.id', opts.reverse_merge(distinct: true))
        end
    end
    has_many :reverse_relationships, foreign_key: "followed_id",
             class_name: "Relationship"
    has_many :followers, through: :reverse_relationships, source: :follower

    has_many :conversation_memberships, foreign_key: "user_id"
    has_many :conversations, through: :conversation_memberships, source: :conversation

    has_one :user_unit, dependent: :destroy

    belongs_to :company
    belongs_to :district
    belongs_to :product_line
    belongs_to :role, class_name: "UserRole"

    has_many :activities


    # Admin
    ROLE_ADMIN = 1

    # Sales
    ROLE_SALES_ENGINEER = 10
    ROLE_APPLICATION_ENGINEER = 11
    ROLE_DESIGN_ENGINEER = 12
    ROLE_IN_HOUSE_ENGINEER = 13
    ROLE_BUSINESS_ENGINEER = 14
    ROLE_ENGINEER = 15

    # Field
    ROLE_DISTRICT_MANAGER = 20
    ROLE_LOCAL_ENGINEER_MANAGER = 21
    ROLE_INVENTORY_MANAGER = 22
    ROLE_FIELD_ENGINEER = 30
    ROLE_FIELD_SPECIALIST = 31
    ROLE_OPERATIONS_COORDINATOR = 32
    ROLE_WAREHOUSE_SPECIALIST = 33
    ROLE_ADMINISTRATOR = 34
    ROLE_FIELD_ENGINEER_TRAINEE = 35
    ROLE_FIELD_SPECIALIST_TRAINEE = 36

    # Support
    ROLE_CORPORATE_MANAGER = 50
    ROLE_RELIABILITY_MANAGER = 51
    ROLE_GENERAL_MANAGER = 52
    ROLE_PRODUCT_LINE_MANAGER = 53
    ROLE_ENGINEERING_MANAGER = 54
    ROLE_DESIGN_MANAGER = 55
    ROLE_APP_SUPPORT_ENGINEER = 56
    ROLE_SUPPORT = 57



    searchable do
        text :district_name, :as => :code_textp do
            district.present? ? district.name : ""
        end

        text :name, :as => :code_textp
        text :email
        time :created_at
        time :updated_at
        integer :company_id

        string :name_sort do
            name
        end
    end


    def active_jobs
        jobs.where(:status => Job::ACTIVE)
    end

    def inactive_jobs
        jobs.where("jobs.status != :active", active: Job::ACTIVE)
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end


=begin
    def self.search(search)
        if search
            where('name LIKE ?', "%#{search}%")
        else
            scoped
        end
    end
=end

    def self.search(options, company)
        Sunspot.search(User) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page]
        end
    end

    def send_pre_job_ready_email(job)
        JobProcessMailer.pre_job_data_complete(self, job).deliver
    end

    def send_post_job_ready_email(job)
        JobProcessMailer.post_job_data_complete(self, job).deliver
    end

    def send_job_shipping_email(job)
        JobProcessMailer.ship_to_field(self, job).deliver
    end

    def send_job_completed_email(job)
        JobProcessMailer.job_complete(self, job).deliver
    end

    def send_added_to_job_email(job)
        JobProcessMailer.added_to_job(self, job).deliver
    end

    def send_reset_password_email(password)
        UserMailer.reset_password(self, password).deliver
    end

    def send_remote_login_password_email(password)
        UserMailer.remote_login_password(self, password).deliver
    end

    def send_welcome_email(user, password)
        UserMailer.registration_confirmation(user, password).deliver
    end

    def send_alert_email(alert)
        UserMailer.alert(self, alert).deliver
    end

    def send_new_message_email(message)
        message.conversation.participants.each do |member|
            if member != self
                UserMailer.new_message(self, message).deliver
            end
        end
    end


    private

    def is_elephant_admin?
        self.elephant_admin?
    end

    def is_admin?
        self.admin?
    end

    def create_remember_token
        if self.remember_token.nil?
            self.remember_token = SecureRandom.urlsafe_base64
        end
    end

end
