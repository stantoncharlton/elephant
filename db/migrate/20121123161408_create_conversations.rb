class CreateConversations < ActiveRecord::Migration
    def change
        create_table :conversations do |t|
            t.integer :company_id

            t.timestamps
        end

        add_index :conversations, :company_id

    end
end
