class AddFailureTemplateIdToFailures < ActiveRecord::Migration
    def change
        add_column :failures, :failure_template_id, :integer

        add_index :failures, :failure_template_id
    end
end
