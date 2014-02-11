class CreateAssetListEntries < ActiveRecord::Migration
    def change
        create_table :asset_list_entries do |t|
            t.integer :company_id
            t.integer :asset_list_id
            t.integer :user_id
            t.integer :quantity
            t.string :description, :length => 500
            t.decimal :inner_diameter
            t.decimal :outer_diameter
            t.decimal :length
            t.integer :up
            t.integer :down

            t.timestamps
        end

        add_index :asset_list_entries, :company_id
        add_index :asset_list_entries, :asset_list_id
    end

end
