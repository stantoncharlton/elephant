class PrimaryTool < ActiveRecord::Base

    before_destroy :destroy_part_memberships

    acts_as_tenant(:company)

    validates_uniqueness_of :tool_id, scope: :job_template_id, :if => :job_not_present

    belongs_to :tool
    belongs_to :job_template
    belongs_to :company
    belongs_to :job

    has_many :template_documents, class_name: "Document", :conditions => {:template => true}
    has_many :documents, dependent: :destroy, :conditions => {:template => false}

    has_many :part_memberships, dependent: :destroy, foreign_key: "primary_tool_id"

    def job_not_present
        self.job_id.nil?
    end

    def destroy_part_memberships
        self.part_memberships.each do |part_membership|
            if part_membership.part.present?
                part_membership.part.status = Part::AVAILABLE
                part_membership.part.current_job = nil
                part_membership.part.save
            end
        end
    end
end
