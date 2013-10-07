class Warehouse < ActiveRecord::Base
    attr_accessible :location,
                    :name

    acts_as_tenant(:company)

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :district_id
    validates :company, presence: true
    validates :district_id, presence: true

    belongs_to :company
    belongs_to :district

    has_many :parts, :conditions => { :template => false }

end
