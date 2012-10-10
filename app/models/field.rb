class Field < ActiveRecord::Base
    attr_accessible :name

    belongs_to :company
    belongs_to :district

    has_many :wells
end
