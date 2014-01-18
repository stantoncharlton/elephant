class ConversationMembership < ActiveRecord::Base
    attr_accessible :deleted

    acts_as_tenant(:company)

    validates :user, presence: true
    validates :conversation, presence: true



    belongs_to :user
    belongs_to :conversation
    belongs_to :company

    validates :user_id, presence: true
    validates :conversation_id, presence: true

    validates_uniqueness_of :user_id, scope: :conversation_id


end
