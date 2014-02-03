class ConversationsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :destroy, :update]


    def index
        @conversations = current_user.conversations.order("updated_at DESC").paginate(page: params[:page], limit: 8)

        if !@conversations.empty? && current_user.alerts
            @new_alerts = current_user.alerts.select { |a| a.alert_type == Alert::NEW_MESSAGE }
            @new_alerts.each do |a|
                if @conversations.first == a.target
                    a.destroy
                end
            end
        end
    end

    def show
        @conversation = Conversation.find_by_id(params[:id])
        not_found unless @conversation.present? && @conversation.company == current_user.company

        if current_user.alerts
            @new_alerts = current_user.alerts.select { |a| a.alert_type == Alert::NEW_MESSAGE && a.target == @conversation }
            @new_alerts.each do |a|
                a.destroy
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

        message_recipients = params[:conversation][:message_recipients]
        params[:conversation].delete(:message_recipients)


        @recipients = message_recipients.split(",")
        @recipients.delete_if { |r| r == current_user.id.to_s }
        if @recipients.empty?
            flash[:error] = "Can't send message to yourself."
            render 'new'
            return
        end

        message_text = params[:conversation][:message_text]
        params[:conversation].delete(:message_text)
        puts message_text

        if message_recipients.blank? || message_text.blank?
            flash[:error] = "Message must have at least 1 recipient and text."
            render 'new'
        end


        #@conversation.set_test_values(message_recipients, message_text)
        @conversation.company = current_user.company

        Conversation.transaction do

            if @conversation.save

                @conversation.add_recipients(current_user, @recipients, current_user.company)
                @conversation.send_message(current_user, message_text)

                flash[:success] = "Message sent."
                redirect_to conversations_path
            else
                flash[:error] = @conversation.errors.full_messages.to_sentence
                render 'new'
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
                Pusher["channel_#{m.user_id}"].trigger('new_message', {
                        conversation_id: @conversation.id,
                        user_id: m.user_id
                })
            end
        end
        #current_user.delay.send_new_message_email(@message)
    end
end
