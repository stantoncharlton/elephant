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

    belongs_to :company
    belongs_to :field

    has_many :jobs
end
