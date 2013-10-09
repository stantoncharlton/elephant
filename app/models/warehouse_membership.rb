class WarehouseMembership < ActiveRecord::Base

    acts_as_tenant(:company)


    belongs_to :user
    belongs_to :warehouse
    belongs_to :company

    validates :user, presence: true
    validates :warehouse, presence: true
end
