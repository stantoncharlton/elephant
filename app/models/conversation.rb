class Conversation < ActiveRecord::Base
    attr_accessible :message_recipients, :message_text
    attr_reader :message_recipients, :message_text

    belongs_to :company

    has_many :messages, order: "created_at ASC"


    has_many :conversation_memberships, foreign_key: "conversation_id"
    has_many :participants, through: :conversation_memberships, source: :user


    def message_recipients=(ids)
        self.message_recipients = ids
    end

    def message_text=(text)
        self.message_text = text
    end


    def add_recipients(user, recipients_string)

        recipients = recipients_string.split(",")
        recipients.push(user.id)

        recipients.each do |recipient_id|
            recipient = ConversationMembership.new
            recipient.user = User.find_by_id(recipient_id)
            recipient.conversation = self
            recipient.save
        end

    end

    def send_message(user, text)
        return false if user.nil? or text.blank?

        message = Message.new(text: text)
        message.user = user
        message.conversation = self

        message.save!

        message
    end

    def self.recipients(user)

        participants.select { |u| u != user }

    end

end
