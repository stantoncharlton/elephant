class AddTotalCirculationToParts < ActiveRecord::Migration
    def change
        add_column :parts, :total_circulation, :decimal, :default => 0.0
    end
end
