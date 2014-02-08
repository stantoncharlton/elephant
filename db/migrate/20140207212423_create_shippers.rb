class CreateShippers < ActiveRecord::Migration
    def change
        create_table :shippers do |t|
            t.integer :company_id
            t.integer :district_id
            t.string :name
            t.string :address_line_1
            t.string :address_line_2
            t.string :city
            t.string :state
            t.string :postal_code
            t.string :phone_number
            t.string :email

            t.timestamps
        end

        add_index :shippers, :company_id
    end
end
