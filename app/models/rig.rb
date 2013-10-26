class Rig < ActiveRecord::Base
  attr_accessible :name

  acts_as_tenant(:company)

  validates :name, presence: true, length: {maximum: 50}
  validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
  validates_presence_of :company

  belongs_to :company

  searchable do
      text :name, :as => :code_textp
      integer :company_id
  end
end
