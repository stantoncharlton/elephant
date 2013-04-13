class DocumentShare < ActiveRecord::Base
    attr_accessible :email,
                    :access_code

    belongs_to :document
    belongs_to :shared_by, class_name: "User"
    belongs_to :job

    belongs_to :forwarded_document_share, class_name: "DocumentShare"

    before_save { |document_share| document_share.email = email.downcase }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
              length: {maximum: 50},
              format: {with: VALID_EMAIL_REGEX}
    validates :document, presence: true
    validates :shared_by, presence: true
    validates :access_code, presence: true


    def send_share_email

    end

end
