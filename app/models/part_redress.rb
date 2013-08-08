class PartRedress < ActiveRecord::Base
    attr_accessible :notes,
                    :received_at,
                    :finished_redress_at

    validates_presence_of :company
    validates_presence_of :job
    validates_presence_of :part

    belongs_to :company
    belongs_to :job
    belongs_to :part

    def self.receive(company, job, part)
        return false if company.nil? or job.nil? or part.nil?

        part_redress = PartRedress.new
        part_redress.job = job
        part_redress.part = part
        part_redress.company = company
        part_redress.received_at = Time.now

        part_redress.save!
        part_redress
    end


    def self.finish_redress(company, job, part, notes)
        return false if company.nil? or job.nil? or part.nil?

        part_redress = PartRedress.where(:job_id => job.id).where(:part_id => part.id).limit(1).first
        part_redress.notes = notes
        part_redress.finished_redress_at = Time.now

        part_redress.save!
        part_redress
    end

end
