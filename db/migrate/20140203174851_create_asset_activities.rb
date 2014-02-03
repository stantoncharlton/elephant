class CreateAssetActivities < ActiveRecord::Migration
    def change
        create_table :asset_activities do |t|
            t.integer :company_id
            t.integer :user_id
            t.integer :part_id
            t.integer :activity_type
            t.string :description
            t.string :user_name

            t.timestamps
        end

        add_index :asset_activities, :company_id
        add_index :asset_activities, :part_id
    end
end
