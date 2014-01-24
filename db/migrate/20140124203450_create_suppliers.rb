class CreateSuppliers < ActiveRecord::Migration
    def change
        create_table :suppliers do |t|
            t.integer :company_id
            t.integer :district_id
            t.string :name
            t.string :location
            t.string :address_line_1
            t.string :address_line_2
            t.string :city
            t.string :state
            t.string :postal_code
            t.string :phone_number
            t.string :email

            t.timestamps
        end
    end
end
