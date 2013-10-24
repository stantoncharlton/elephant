class CreateMudRecords < ActiveRecord::Migration
    def change
        create_table :mud_records do |t|
            t.integer :company_id
            t.integer :user_id
            t.integer :document_id

            t.string :type
            t.decimal :weight
            t.decimal :visc
            t.decimal :chlorides
            t.decimal :yp
            t.decimal :pv
            t.decimal :ph
            t.decimal :gas
            t.decimal :sand
            t.decimal :wl
            t.decimal :solid
            t.decimal :bht
            t.decimal :flow_t
            t.decimal :oil

            t.timestamps
        end

        add_index :mud_records, :document_id
    end
end
