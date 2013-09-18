class Issue < ActiveRecord::Base
    attr_accessible :status

    belongs_to :company
    belongs_to :failure
    belongs_to :job

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
        issue
    end

    def remove(failure)
        issue = Issue.find_by_failure_id(failure.id)
        issue.destroy
    end


end
