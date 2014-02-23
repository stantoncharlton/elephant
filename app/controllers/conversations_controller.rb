class ConversationsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :destroy, :update]


    def index
        @conversations = current_user.conversations.order("updated_at DESC").paginate(page: params[:page], limit: 8)

        if !@conversations.empty? && current_user.alerts
            @new_alerts = current_user.alerts.select { |a| a.alert_type == Alert::NEW_MESSAGE }
            @new_alerts.each do |a|
                if @conversations.first == a.target && !params[:check_new].present?
                    a.destroy
                end
            end
        end
    end

    def show
        @conversation = Conversation.find_by_id(params[:id])
        not_found unless @conversation.present? && @conversation.company == current_user.company

        mark_seen = params[:seen].nil? || params[:seen] == 'true'
        if current_user.alerts.any?
            @new_alerts = current_user.alerts.select { |a| a.alert_type == Alert::NEW_MESSAGE && a.target == @conversation }
            if mark_seen && !params[:check_new].present?
                @new_alerts.each do |a|
                    a.destroy
                end
            end
        end

    end

    def new
        @conversation = Conversation.new

        @recipients = Array.new
        user = User.find_by_id(params["to_user_id"])
        if !user.nil? and user.company == current_user.company
            @recipients << user
        end

    end

    def create

        @conversation = Conversation.new()

        if params[:conversation][:message_recipients].present?
            message_recipients = params[:conversation][:message_recipients]
            params[:conversation].delete(:message_recipients)

            @recipients = message_recipients.split(",")
            @recipients.delete_if { |r| r == current_user.id.to_s }
        end

        @recipients = []
        params.each do |k, v|
            if k.starts_with?("recipient")
                if v != current_user.id
                    @recipients << v
                end
            end
        end

        if @recipients.empty?
            @conversation.errors.add(:conversation, "Can't send message to yourself.")
            flash[:error] = "Can't send message to yourself."
            if request.format == 'html'
                render 'new'
            end
            return
        end

        message_text = params[:conversation][:message_text]
        params[:conversation].delete(:message_text)

        if message_text.blank?
            @conversation.errors.add(:conversation, "Message must have text.")
            flash[:error] = "Message must have text."
            if request.format == 'html'
                render 'new'
            end
            return
        end

        new_conversation = true
        @conversation.company = current_user.company

        recipient = User.find_by_id(@recipients.first)
        if recipient.present?
            conversations = Conversation.includes(:conversation_memberships).where("conversations.id IN (#{current_user.conversations.select("conversations.id").to_sql})").where("conversation_memberships.user_id = ?", recipient.id)
            if conversations.any?
                if @recipients.count == 1 && conversations.count == 1 && conversations.first.conversation_memberships.count == 2
                    @conversation = conversations.first
                    new_conversation = false
                else
                    conversations.each do |c|
                        users = c.participants.to_a
                        if users.count == @recipients.count + 1
                            all_match = true
                            @recipients.each do |r|
                                all_match = users.select { |u| u.id == r.to_i }.any?
                            end
                            if all_match
                                @conversation = c
                                new_conversation = false
                                break
                            end
                        end
                    end
                end
            end
        end

        Conversation.transaction do

            if @conversation.save

                if new_conversation
                    @conversation.add_recipients(current_user, @recipients, current_user.company)
                else
                    @conversation.touch
                end
                @conversation.send_message(current_user, message_text)

                if request.format == 'html'
                    flash[:success] = "Message sent."
                    redirect_to conversations_path
                end
            else
                if request.format == 'html'
                    flash[:error] = @conversation.errors.full_messages.to_sentence
                    render 'new'
                end
            end
        end
    end

    def destroy
        @conversation = Conversation.find_by_id(params[:id])

        @membership = @conversation.conversation_memberships.where(:user_id => current_user.id).first
        @membership.update_attribute(:deleted, true)

        all_deleted = true
        @conversation.conversation_memberships.each do |m|
            if !m.deleted
                all_deleted = false
            end
        end

        if all_deleted
            alerts = Alert.where("alerts.alert_type = ?", Alert::NEW_MESSAGE).where("alerts.target_id = ?", @conversation.id)
            alerts.each do |a|
                a.destroy
            end
            @conversation.destroy
        end
        redirect_to conversations_path
    end

    def update

        message_text = params[:conversation][:message_text]
        params[:conversation].delete(:message_text)


        Conversation.transaction do
            @conversation = Conversation.find_by_id(params[:id])
            not_found unless @conversation.company == current_user.company

            @last_message = @conversation.messages.last

            @conversation.touch

            @message = @conversation.send_message(current_user, message_text)

            @conversation.conversation_memberships.each do |m|
                m.update_attribute(:deleted, false)
                if m.user != current_user
                    Pusher["private-channel_#{m.user_id}"].trigger('new_message', {
                            conversation_id: @conversation.id,
                            user_id: m.user_id
                    })
                end
            end
        end
        #current_user.delay.send_new_message_email(@message)
    end
end
