class AddJobPartMembershipToPartMemberships < ActiveRecord::Migration
    def change
        add_column :part_memberships, :job_part_membership_id, :integer
    end
end
