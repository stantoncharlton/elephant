class Field < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false

    belongs_to :company
    belongs_to :district

    has_many :wells

end
