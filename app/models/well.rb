class Well < ActiveRecord::Base
    attr_accessible :name,
                    :rig_name,
                    :measured_depth,
                    :true_vertical_depth,
                    :water_depth,
                    :offshore,
                    :bottom_hole_temperature,
                    :bottom_hole_formation_pressure,
                    :frac_pressure,
                    :fuild_type,
                    :fluid_weight,
                    :max_deviation,
                    :bottom_deviation


    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false

    validates :measured_depth, numericality: true, allow_nil: true
    validates :true_vertical_depth, numericality: true, allow_nil: true
    validates :water_depth, numericality: true, allow_nil: true
    validates :bottom_hole_temperature, numericality: true, allow_nil: true
    validates :bottom_hole_formation_pressure, numericality: true, allow_nil: true
    validates :frac_pressure, numericality: true, allow_nil: true
    validates :fluid_weight, numericality: true, allow_nil: true
    validates :max_deviation, numericality: true, allow_nil: true
    validates :bottom_deviation, numericality: true, allow_nil: true


    belongs_to :company
    belongs_to :field

    has_many :jobs
end
