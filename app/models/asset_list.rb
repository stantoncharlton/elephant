class AssetList < ActiveRecord::Base
  attr_accessible :comment

  acts_as_tenant(:company)

  validates :comment, presence: true, length: {minimum: 1, maximum: 500}
  validates_presence_of :company_id
  validates_presence_of :job_id
  validates_presence_of :document_id
  validates_presence_of :user_id

  belongs_to :document
  belongs_to :job
  belongs_to :company
  belongs_to :user

end