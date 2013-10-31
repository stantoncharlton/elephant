class CreateDocumentRevisions < ActiveRecord::Migration
  def change
    create_table :document_revisions do |t|
      t.integer :company_id
      t.integer :document_id
      t.integer :user_id
      t.string :user_name
      t.string :url
      t.datetime :upload_date

      t.timestamps
    end
  end
end
