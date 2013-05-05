class Client < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
    validates :company, presence: true

    belongs_to :company
    belongs_to :country

    has_many :jobs, order: "close_date DESC, created_at DESC"

    searchable do
        text :name, :as => :code_textp
        time :created_at
        time :updated_at
        integer :company_id

        string :name_sort do
            name
        end

        text :country_name, :as => :code_textp do
            country.present? ? country.name : ""
        end
    end


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def self.from_company_for_user(client, options, user, company)
        Sunspot.search(Job) do
            with(:client_id, client.id)
            any_of do
                if user.role.limit_to_assigned_jobs?
                    with(:job_membership, user.id)
                elsif user.role.limit_to_district?
                    with(:district_id, user.district.id)
                elsif user.role.limit_to_product_line? && !user.product_line.nil?
                    with(:product_line_id, user.product_line.id)
                end
            end
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end


    def self.search(options, company)
        Sunspot.search(Client) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end

end
