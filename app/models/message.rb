class Message < ActiveRecord::Base
    attr_accessible :text


    validates_presence_of :user
    validates_presence_of :conversation

    belongs_to :user
    belongs_to :conversation
    belongs_to :company



end
