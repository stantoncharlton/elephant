class ConversationsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :destroy, :update]


    def index
        @conversations = current_user.conversations.order("updated_at DESC").paginate(page: params[:page], limit: 8)

        if !@conversations.empty? && current_user.alerts
            new_alerts = current_user.alerts.select { |a| a.target == @conversations.first }
            if !new_alerts.empty?
                new_alerts.first.destroy
            end
        end

    end

    def show
        @conversation = Conversation.find_by_id(params[:id])
        not_found unless @conversation.present? && @conversation.company == current_user.company
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
        puts message_recipients

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

    end

    def update

        message_text = params[:conversation][:message_text]
        params[:conversation].delete(:message_text)
        puts message_text

        @conversation = Conversation.find_by_id(params[:id])
        not_found unless @conversation.company == current_user.company

        @conversation.touch

        @message = @conversation.send_message(current_user, message_text)
        current_user.delay.send_new_message_email(@message)
    end
end
