class JobMembership < ActiveRecord::Base
  #attr_accessible :job_id, :user_id

  belongs_to :user
  belongs_to :job

  validates :user_id, presence: true
  validates :job_id, presence: true
end
