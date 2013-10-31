class DocumentRevision < ActiveRecord::Base
    attr_accessible :upload_date,
                    :url,
                    :user_name

    acts_as_tenant(:company)

    validates :url, presence: true
    validates :company, presence: true

    belongs_to :document
    belongs_to :company
    belongs_to :user


    def full_url
        if !self.url.blank?
            s3 = AWS::S3.new
            obj = s3.buckets['elephant-docs'].objects[self.url].url_for(:read)
            obj.to_s
        else
            ''
        end
    end

end
