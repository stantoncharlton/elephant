class Message < ActiveRecord::Base
    attr_accessible :text

    acts_as_tenant(:company)


    validates_presence_of :user
    validates_presence_of :conversation

    belongs_to :user
    belongs_to :conversation
    belongs_to :company



end
