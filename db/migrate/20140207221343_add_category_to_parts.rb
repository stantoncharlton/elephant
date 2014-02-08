class AddCategoryToParts < ActiveRecord::Migration
    def change
        add_column :parts, :category, :string
        add_column :parts, :manufacturer, :string
        add_column :parts, :max_hours, :decimal
    end
end
