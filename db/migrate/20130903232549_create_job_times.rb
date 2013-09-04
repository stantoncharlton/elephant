class CreateJobTimes < ActiveRecord::Migration
    def change
        create_table :job_times do |t|
            t.integer :company_id
            t.integer :job_id
            t.integer :user_id
            t.datetime :time_for
            t.integer :status
            t.integer :hours

            t.timestamps
        end

        add_index :job_times, :company_id
        add_index :job_times, :user_id
        add_index :job_times, :job_id
    end
end
