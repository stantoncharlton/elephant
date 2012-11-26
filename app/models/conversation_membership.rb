class ConversationMembership < ActiveRecord::Base


    belongs_to :user
    belongs_to :conversation

    validates :user_id, presence: true
    validates :conversation_id, presence: true

    validates_uniqueness_of :user_id, scope: :conversation_id


end
