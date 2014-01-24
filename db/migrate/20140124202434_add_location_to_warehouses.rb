class AddLocationToWarehouses < ActiveRecord::Migration
    def change
        add_column :warehouses, :address_line_1, :string
        add_column :warehouses, :address_line_2, :string
        add_column :warehouses, :city, :string
        add_column :warehouses, :postal_code, :string
        add_column :warehouses, :phone_number, :string
        add_column :warehouses, :email, :string
    end
end
