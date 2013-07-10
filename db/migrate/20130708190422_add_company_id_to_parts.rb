class AddCompanyIdToParts < ActiveRecord::Migration
    def change
        add_column :parts, :company_id, :integer

        add_index :parts, :company_id
    end
end
