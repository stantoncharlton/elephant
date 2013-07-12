class Part < ActiveRecord::Base
    attr_accessible :name,
                    :part_number,
                    :status,
                    :template,
                    :active,
                    :material_number,
                    :serial_number,
                    :district_serial_number,
                    :total_count,
                    :on_hand_count,
                    :total_uses,
                    :location

    validates_presence_of :company
    validates_presence_of :material_number
    validates_uniqueness_of :material_number, :case_sensitive => false, scope: :company_id, :if => :template?
    validates_presence_of :serial_number, :if => :not_template
    validates_presence_of :district_serial_number, :if => :not_template
    validates_presence_of :name, :if => :template?
    validates_presence_of :master_part, :if => :not_template


    belongs_to :company
    belongs_to :district
    belongs_to :current_job, class_name: "Job"
    belongs_to :master_part, class_name: "Part"
    belongs_to :primary_tool

    has_many :parts, foreign_key: "master_part_id"

    has_many :part_memberships, foreign_key: "part_id"
    has_many :jobs, through: :part_memberships, source: :job


    AVAILABLE = 1
    ON_JOB = 2
    USED = 3
    IN_REDRESS = 4


    searchable do
        text :name, :as => :code_textp do
            master_part.present? ? master_part.name : name
        end

        time :created_at
        time :updated_at
        integer :company_id
        text :part_number
        text :material_number
        text :serial_number
        text :district_serial_number
        integer :district_id

        string :name_sort do
            name
        end
    end

    def not_template
        !self.template?
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("parts.district_serial_number_id ASC")
    end

    def self.search(options, company)
        Sunspot.search(Part) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end

    def status_string
        case self.status
            when AVAILABLE
                return "Available"
            when ON_JOB
                return "On Job"
            when USED
                return "Waiting for Redress"
            when IN_REDRESS
                return "In Redress"
        end
    end
end
