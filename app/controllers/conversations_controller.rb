class ConversationsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :destroy, :update]


    def index
        @conversations = current_user.conversations.order("updated_at DESC")
    end

    def show
        @conversation = Conversation.find_by_id(params[:id])
        not_found unless @conversation.company == current_user.company
    end

    def new
        @conversation = Conversation.new
    end

    def create
        message_recipients = params[:conversation][:message_recipients]
        params[:conversation].delete(:message_recipients)
        puts message_recipients

        message_text = params[:conversation][:message_text]
        params[:conversation].delete(:message_text)
        puts message_text

        if message_recipients.blank? || message_text.blank?
            flash[:error] = "Message must have at least 1 recipient and text."
            render 'new'
        end

        @conversation = Conversation.new()
        #@conversation.set_test_values(message_recipients, message_text)
        @conversation.company = current_user.company

        Conversation.transaction do

            if @conversation.save

                @conversation.add_recipients(current_user, message_recipients)
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
    end
end
