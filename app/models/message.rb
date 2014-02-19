class Message < ActiveRecord::Base
    attr_accessible :text

    acts_as_tenant(:company)

    require 'link_url'

    validates_presence_of :user
    validates_presence_of :conversation

    belongs_to :user
    belongs_to :conversation
    belongs_to :company


    def link_text
        LinkUrl.convert(self.text)
    end

end
