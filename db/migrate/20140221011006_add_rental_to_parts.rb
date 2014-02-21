class AddRentalToParts < ActiveRecord::Migration
    def change
        add_column :parts, :rental, :boolean, :default => false
        add_column :parts, :asset_type, :integer, :default => 0
    end
end
