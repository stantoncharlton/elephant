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
                    :verified_networks,
                    :invalid_login_attempts

    has_secure_password

    acts_as_tenant(:company)

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
    has_many :jobs, through: :job_memberships, source: :job, order: "jobs.close_date DESC, jobs.created_at DESC", uniq: true do
        def count(column_name = nil, opts = {})
            super(column_name || 'jobs.id', opts.reverse_merge(distinct: true))
        end
    end

    has_many :warehouse_memberships, foreign_key: "user_id"
    has_many :warehouses, through: :warehouse_memberships, source: :warehouse, order: "warehouses.name ASC"

    has_many :reverse_relationships, foreign_key: "followed_id",
             class_name: "Relationship"
    has_many :followers, through: :reverse_relationships, source: :follower

    has_many :conversation_memberships, foreign_key: "user_id"
    has_many :conversations, through: :conversation_memberships, source: :conversation

    has_one :user_unit, dependent: :destroy

    belongs_to :company
    belongs_to :district
    belongs_to :product_line
    belongs_to :segment
    belongs_to :division
    belongs_to :role, class_name: "UserRole"

    has_many :activities



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

    def role
        UserRole.from_user self
    end

    def active_jobs
        jobs.where(:status => Job::ACTIVE)
    end

    def inactive_jobs
        jobs.where("jobs.status != :active", active: Job::ACTIVE)
    end

    def active_or_recently_closed_jobs
        jobs.where("jobs.status = :active OR jobs.close_date > :close_date", active: Job::ACTIVE, close_date: 5.days.ago)
    end

    def new_alerts
        self.alerts.includes(:company, :created_by, :user, :target).includes(job: { job_template: { primary_tools: :tool } }).where("alert_type != 3 AND expiration is NULL")
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def title
        UserRole.from_role(self.role_id, Company.cached_find(self.company_id)).title
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
            paginate :page => options[:page], :per_page => 20
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

    def api_key
        key = ApiKey.new
        key.user = self
        key.save
        key.access_token
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
