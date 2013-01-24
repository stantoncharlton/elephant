class UserUnit < ActiveRecord::Base
  attr_accessible :area,
                  :length_inner,
                  :length_outer,
                  :pressure,
                  :rate,
                  :temperature,
                  :volume

  belongs_to :user
end
