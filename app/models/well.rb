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


    belongs_to :company
    belongs_to :field

    has_many :jobs
end
