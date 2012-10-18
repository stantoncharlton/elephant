class User < ActiveRecord::Base
    attr_accessible :email, :location, :name,
                    :phone_number, :position_title,
                    :password, :password_confirmation,
                    :admin, :write_access, :create_access
    has_secure_password

    after_initialize :init

    before_save { |user| user.email = email.downcase }
    before_save :create_remember_token

    after_create :send_welcome_email

    validates :name, presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
              length: {maximum: 50},
              format: {with: VALID_EMAIL_REGEX},
              uniqueness: {case_sensitive: false}
    validates :company, presence: true
    validates :password, presence: true, length: {minimum: 6}
    validates :password_confirmation, presence: true

    #validates_presence_of :district, unless: Proc.new { |ex| ex.admin == true }


    belongs_to :company
    belongs_to :district

    has_many :activities


    def init
        self.write_access  ||= true
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def self.search(search)
        if search
            where('name LIKE ?', "%#{search}%")
        else
            scoped
        end
    end


private

    def create_remember_token
        self.remember_token = SecureRandom.urlsafe_base64
    end

    def send_welcome_email
        UserMailer.registration_confirmation(self).deliver
    end
end
