class CreateShipments < ActiveRecord::Migration
    def change
        create_table :shipments do |t|
            t.integer :company_id
            t.integer :user_id
            t.integer :accepted_by_id
            t.datetime :accepted_at
            t.integer :from_type
            t.integer :to_type
            t.integer :from_id
            t.integer :to_id
            t.integer :status
            t.integer :district_id

            t.timestamps
        end
    end
end
