class PrimaryTool < ActiveRecord::Base
    attr_accessible :comments,
                    :serial_number,
                    :received,
                    :simple_tracking,
                    :template

    before_destroy :destroy_part_memberships

    acts_as_tenant(:company)

    validates_uniqueness_of :tool_id, scope: :job_template_id, :if => :job_not_present

    validates :comments, length: {minimum: 0, maximum: 500}

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

    def duplicate job, user
        existing_tool = self
        tool = PrimaryTool.new
        tool.template = false
        tool.tool = existing_tool.tool
        tool.job = job
        not_found unless tool.job.company == user.company
        tool.job_template = existing_tool.job_template
        tool.company = user.company

        if tool.save
            existing_tool.documents.order("created_at ASC").each do |document|
                new_document = document.duplicate
                new_document.url = nil
                new_document.primary_tool_id = tool.id
                new_document.save
            end
            existing_tool.part_memberships.where(:template => true).order("created_at ASC").each do |part_membership|
                new_part_membership = part_membership.duplicate
                new_part_membership.part = nil
                new_part_membership.template = true
                new_part_membership.primary_tool = tool
                new_part_membership.optional = true
                new_part_membership.save
            end
        end

        tool
    end
end
