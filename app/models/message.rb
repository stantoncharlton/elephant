class Message < ActiveRecord::Base
    attr_accessible :text

    belongs_to :user
    belongs_to :conversation



end
