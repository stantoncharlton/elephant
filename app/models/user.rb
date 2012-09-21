class User < ActiveRecord::Base
    attr_accessible :district_id, :email, :location, :name,
                    :phone_number, :position_title,
                    :password, :password_confirmation,
                    :admin, :write_access, :create_access
    has_secure_password

    before_save { |user| user.email = email.downcase }
    before_save :create_remember_token

    validates :name, presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
              length: {maximum: 50},
              format: {with: VALID_EMAIL_REGEX},
              uniqueness: {case_sensitive: false}
    validates :company, presence: true
    validates :password, presence: true, length: {minimum: 6}
    validates :password_confirmation, presence: true


    belongs_to :company


    private

    def create_remember_token
        self.remember_token = SecureRandom.urlsafe_base64
    end
end
