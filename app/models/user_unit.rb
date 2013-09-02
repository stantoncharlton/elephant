class UserUnit < ActiveRecord::Base
  attr_accessible :area,
                  :length_inner,
                  :length_outer,
                  :pressure,
                  :rate,
                  :temperature,
                  :volume,
                  :weight,
                  :weight_casing,
                  :weight_gradient,
                  :viscosity

  belongs_to :user
  belongs_to :company

end
