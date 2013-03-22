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
                    :support_email

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
    validates :company, presence: true
    validates :country, presence: true

    belongs_to :company
    belongs_to :country
    belongs_to :state

    has_many :fields, order: "name ASC"
    has_many :jobs, order: "created_at DESC"


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
            with(:district_id, district.id)
            if !user.role.district_read?
                with(:job_membership, user.id)
            end
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end


    def self.search(options, company)
        Sunspot.search(District) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page]
        end
    end

end
