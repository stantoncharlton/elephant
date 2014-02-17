class District < ActiveRecord::Base
    attr_accessible :name,
                    :time_zone,
                    :location,
                    :region,
                    :address_line_1,
                    :address_line_2,
                    :city,
                    :postal_code,
                    :phone_number,
                    :support_email,
                    :master

    acts_as_tenant(:company)


    validates :name, presence: true, length: {maximum: 50}
    validates :company, presence: true
    validates :country, presence: true

    belongs_to :company
    belongs_to :country
    belongs_to :state

    belongs_to :master_district, class_name: "District"

    has_many :districts, foreign_key: "master_district_id", dependent: :destroy
    has_many :fields, order: "name ASC"
    has_many :jobs, order: "jobs.close_date DESC, jobs.created_at DESC"

    has_many :parts, :conditions => { :template => false }
    has_many :warehouses
    has_many :suppliers
    has_many :shippers


    searchable do
        text :name, :as => :code_textp
        text :region, :as => :code_textp
        text :city, :as => :code_textp

        text :country_name, :as => :code_textp do
            country.present? ? country.name : ""
        end

        text :state_name, :as => :code_textp do
            state.present? ? state.name : ""
        end

        time :created_at
        time :updated_at
        integer :company_id
        boolean :master

        string :name_sort do
            name
        end
    end


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def personnel
        User.where("district_id = ?", self.id)
    end

    def self.from_company_for_user(district, options, user, company)
        Sunspot.search(Job) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            any_of do
                if user.role.limit_to_assigned_jobs?
                    with(:job_membership, user.id)
                elsif user.role.limit_to_district?
                    with(:district_id, user.district.id)
                elsif user.role.limit_to_product_line? && !user.product_line.nil?
                    with(:product_line_id, user.product_line.id)
                end
            end
            with(:district_id, district.id)
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end


    def self.search(options, company, master)
        Sunspot.search(District) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            with(:master, master)
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end

    def map_search
       (name || '') + " " + (city || '') + " " + (state.present? ? state.name : "") + " " + (country.name || '')
    end

end
