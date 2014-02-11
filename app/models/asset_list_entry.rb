class AssetListEntry < ActiveRecord::Base
  attr_accessible :quantity,
                  :description,
                  :inner_diameter,
                  :outer_diameter,
                  :length,
                  :up,
                  :down


  acts_as_tenant(:company)

  validates :description, presence: true, length: {minimum: 1, maximum: 500}
  validates_presence_of :company_id
  validates_presence_of :asset_list_id
  validates_presence_of :user_id

  belongs_to :company
  belongs_to :asset_list
  belongs_to :user


end
