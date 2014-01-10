class Issue < ActiveRecord::Base
    attr_accessible :status,
                    :failure_at,
                    :part_serial_number,
                    :responsible_by_name,
                    :accountable

    acts_as_tenant(:company)

    belongs_to :company
    belongs_to :failure
    belongs_to :job
    belongs_to :part

    belongs_to :responsible_by, class_name: "User"

    has_many :job_notes
    has_many :documents, :dependent => :destroy, as: :owner, :class_name => "Document"

    OPEN = 1
    CLOSED = 2

    def status_string
        case self.status
            when OPEN
                "Open"
            when CLOSED
                "Closed"
        end
    end

    def self.add(failure, company, job)
        issue = Issue.new(status: OPEN)
        issue.failure = failure
        issue.company = company
        issue.job = job
        issue.save

        document = Document.new
        document.name = "Issue Report"
        document.category = Document::ISSUES
        document.document_type = Document::DOCUMENT
        document.read_only = false
        document.ordering = 0
        document.template = false
        document.owner = issue
        document.company = company
        document.save

        issue
    end

    def self.remove(failure)
        issue = Issue.find_by_failure_id(failure.id)
        issue.destroy
    end


end
