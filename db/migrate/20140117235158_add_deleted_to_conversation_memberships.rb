class AddDeletedToConversationMemberships < ActiveRecord::Migration
    def change
        add_column :conversation_memberships, :deleted, :boolean, :default => false
    end
end
