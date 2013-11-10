class CrewMembership < ActiveRecord::Base
  attr_accessible :user_name


  acts_as_tenant(:company)

  after_save :after_save
  after_destroy :after_destroy

  belongs_to :user
  belongs_to :crew
  belongs_to :company

  validates :user, presence: true
  validates :job, presence: true


private
  def after_save
      update_counter_cache
  end

  def after_destroy
      update_counter_cache
  end

  def update_counter_cache
      self.crew.crew_memberships_count = self.crew.crew_memberships_count.count()
      self.crew.save
  end
end
