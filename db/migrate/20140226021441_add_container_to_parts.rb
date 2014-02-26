class AddContainerToParts < ActiveRecord::Migration
    def change
        add_column :parts, :container, :boolean, :default => false
        add_column :parts, :container_id, :integer
    end
end
