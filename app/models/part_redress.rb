class PartRedress < ActiveRecord::Base
    attr_accessible :notes

    validates_presence_of :company
    validates_presence_of :job
    validates_presence_of :part

    belongs_to :company
    belongs_to :job
    belongs_to :part

    def self.add(company, job, part, notes)
        return false if company.nil? or job.nil? or part.nil?

        part_redress = PartRedress.new(notes: notes)
        part_redress.job = job
        part_redress.part = part
        part_redress.company = company

        part_redress.save!
        part_redress
    end

end
