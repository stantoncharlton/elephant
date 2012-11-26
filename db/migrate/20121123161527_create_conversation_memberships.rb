class CreateConversationMemberships < ActiveRecord::Migration
    def change
        create_table :conversation_memberships do |t|
            t.integer :user_id
            t.integer :conversation_id

            t.timestamps
        end

        add_index :conversation_memberships, :user_id
        add_index :conversation_memberships, :conversation_id
        add_index :conversation_memberships, [:user_id, :conversation_id]

    end
end
