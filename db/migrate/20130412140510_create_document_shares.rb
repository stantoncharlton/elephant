class CreateDocumentShares < ActiveRecord::Migration
    def change
        create_table :document_shares do |t|
            t.integer :document_id
            t.string :email
            t.string :access_code
            t.integer :shared_by
            t.integer :job_id
            t.integer :forwarded_document_share

            t.timestamps
        end

        add_index :document_shares, :document_id
        add_index :document_shares, :email
        add_index :document_shares, [:document_id, :email], unique: true
        add_index :document_shares, :job_id
        add_index :document_shares, :forwarded_document_share
    end
end
