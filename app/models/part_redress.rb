class PartRedress < ActiveRecord::Base
    attr_accessible :notes,
                    :received_at,
                    :finished_redress_at,
                    :received_by_name,
                    :finished_redress_by_name,
                    :no_redress

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :part

    validates :notes, length: {minimum: 0, maximum: 500}

    belongs_to :company
    belongs_to :job
    belongs_to :part

    belongs_to :received_by, class_name: "User"
    belongs_to :finished_redress_by, class_name: "User"

    has_many :notes, :dependent => :destroy, as: :owner, :class_name => "JobNote"

    def documents
       Document.where(:company_id => company_id).where("documents.owner_id = ?", self.id).where("documents.owner_type = 'PartRedress'").order("created_at ASC")
    end

    def self.receive(company, part, user)
        return false if company.nil? || part.nil?

        part_redress = PartRedress.new
        part_redress.part = part
        part_redress.company = company
        part_redress.received_at = Time.now
        part_redress.received_by = user
        part_redress.received_by_name = user.present? ? user.name : ''

        part_redress.save!
        part_redress
    end


    def self.finish_redress(company, part, user)
        return false if company.nil? || part.nil?

        part_redress = PartRedress.where(:part_id => part.id).order("created_at ASC").last
        part_redress.finished_redress_at = Time.now
        part_redress.finished_redress_by = user
        part_redress.finished_redress_by_name = user.present? ? user.name : ''

        part_redress.documents.each do |document|
            if document.url.nil?
                document.destroy
            end
        end


        part_redress.save!
        part_redress
    end


    def self.transfer(company, job, part, user)
        return false if company.nil? or job.nil? or part.nil?

        part_redress = PartRedress.new
        part_redress.job = job
        part_redress.part = part
        part_redress.no_redress = true
        part_redress.company = company
        part_redress.received_at = Time.now
        part_redress.received_by = user
        part_redress.received_by_name = user.present? ? user.name : ''
        part_redress.finished_redress_at = Time.now
        part_redress.finished_redress_by = user
        part_redress.finished_redress_by_name = user.present? ? user.name : ''

        part_redress.save!
        part_redress
    end


    def self.start_redress_no_job(company, part, user)
        return false if company.nil? or part.nil?

        part_redress = PartRedress.new
        part_redress.part = part
        part_redress.company = company
        part_redress.received_at = Time.now
        part_redress.received_by = user
        part_redress.received_by_name = user.present? ? user.name : ''

        part_redress.save!
        part_redress
    end

end
