class DocumentShare < ActiveRecord::Base
    attr_accessible :email,
                    :access_code

    attr_accessible :job_role_id

    belongs_to :document
    belongs_to :shared_by, class_name: "User"
    belongs_to :job

    belongs_to :forwarded_document_share, class_name: "DocumentShare"

    validates :document, presence: true
    validates :shared_by, presence: true
    validates :access_code, presence: true

end
