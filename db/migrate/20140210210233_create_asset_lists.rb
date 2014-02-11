class CreateAssetLists < ActiveRecord::Migration
    def change
        create_table :asset_lists do |t|
            t.integer :company_id
            t.integer :document_id
            t.integer :job_id
            t.integer :user_id
            t.string :comment, :length => 500

            t.timestamps
        end

        add_index :asset_lists, :company_id
        add_index :asset_lists, :job_id
    end
end
