class AddDistrictIdToParts < ActiveRecord::Migration
  def change
    add_column :parts, :district_id, :integer

    add_index :parts, :district_id
  end
end
