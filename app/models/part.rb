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
                    :location,
                    :below_rotary,
                    :above_rotary

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :material_number
    validates_uniqueness_of :material_number, :case_sensitive => false, scope: [:company_id, :district_id], :if => :template
    validates_uniqueness_of :serial_number, :case_sensitive => false, scope: :company_id, :if => :not_template
    validates_presence_of :serial_number, :if => :not_template
    validates_presence_of :name, :if => :template
    validates_presence_of :master_part, :if => :not_template


    belongs_to :company
    belongs_to :district
    belongs_to :current_job, class_name: "Job"
    belongs_to :master_part, class_name: "Part"
    belongs_to :primary_tool
    belongs_to :warehouse

    has_many :parts, foreign_key: "master_part_id", order: "serial_number ASC"

    has_many :part_memberships, foreign_key: "part_id"
    has_many :part_redresses, order: "created_at DESC"
    has_many :jobs, through: :part_memberships, source: :job
    has_many :issues, order: "failure_at DESC"

    AVAILABLE = 1
    ON_JOB = 2
    USED = 3
    IN_REDRESS = 4
    DECOMMISSIONED = 5

    SHIPPING = 10


    searchable do
        text :name, :as => :code_textp do
            master_part.present? ? master_part.name : name
        end

        text :serial_number, :as => :code_textp do
            serial_number
        end

        time :created_at
        time :updated_at
        integer :company_id
        text :part_number
        text :material_number_text do
            material_number
        end
        text :district_serial_number
        string :material_number
        integer :warehouse_id
        integer :district_id
        integer :master_district_id do
            district.present? && district.master_district.present? ? district.master_district_id : nil
        end
        boolean :template
        integer :status

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

    def self.search_no_district(options, company)
        Sunspot.search(Part) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort, :desc
            paginate :page => options[:page], :per_page => 20
        end
    end

    def self.search_master_district(options, company, district_id)
        Sunspot.search(Part) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            with(:master_district_id, district_id)
            order_by :name_sort, :desc
            paginate :page => options[:page], :per_page => 20
        end
    end

    def self.search(options, company, district, current_user)
        Sunspot.search(Part) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            if current_user.role.limit_to_assigned_jobs?
                any_of do
                    with(:district_id, district.id)
                end
            else
                any_of do
                    with(:district_id, district.id)
                end
            end
            order_by :name_sort, :desc
            paginate :page => options[:page], :per_page => 20
        end
    end

    def self.search_parts(options, company, material_number, district, current_user)

        Sunspot.search(Part) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            if current_user.role.limit_to_assigned_jobs?
                any_of do
                    with(:district_id, district.id)
                end
            else
                any_of do
                    with(:district_id, district.id)
                end
            end
            with(:material_number, material_number)
            with(:template, false)
            with(:status, Part::AVAILABLE)
            order_by :name_sort, :desc
            paginate :page => options[:page], :per_page => 20
        end
    end

    def status_string
        case self.status
            when AVAILABLE
                if self.warehouse.present?
                    return "Available - " + self.warehouse.name
                else
                    return "Available"
                end
            when ON_JOB
                return "On Job"
            when USED
                if self.warehouse.present?
                    return "Awaiting Maintenance - " + self.warehouse.name
                else
                    return "Awaiting Maintenance"
                end
            when IN_REDRESS
                if self.warehouse.present?
                    return "In Maintenance - " + self.warehouse.name
                else
                    return "In Maintenance"
                end
            when SHIPPING
                return "Shipping"
            when DECOMMISSIONED
                return "Decommissioned"
        end
    end

    def status_css
        case self.status
            when AVAILABLE
                return "part-box-available"
            when ON_JOB
                return "part-box-job"
            when USED
                return "part-box-maintenance"
            when IN_REDRESS
                return "part-box-maintenance"
            when SHIPPING
                return "part-box-maintenance"
            when DECOMMISSIONED
                return ""
        end
    end
end
