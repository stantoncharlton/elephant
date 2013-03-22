class AddCountryIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :country_id, :integer
  end
end
