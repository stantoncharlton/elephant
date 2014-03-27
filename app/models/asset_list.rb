class AssetList < ActiveRecord::Base
    attr_accessible :comment

    acts_as_tenant(:company)

    validates :comment, length: {minimum: 0, maximum: 500}
    validates_presence_of :company_id
    validates_presence_of :job_id

    belongs_to :job
    belongs_to :company
    belongs_to :user

    has_many :asset_list_entries, order: "created_at ASC"

end