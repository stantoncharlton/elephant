class Job < ActiveRecord::Base
    attr_accessible :client_contact_name,
                    :start_date,
                    :end_date


    validates_presence_of :company
    validates_presence_of :client
    validates_presence_of :district
    validates_presence_of :field
    validates_presence_of :well
    validates_presence_of :job_template

    belongs_to :company
    belongs_to :client
    belongs_to :district
    belongs_to :field
    belongs_to :well
    belongs_to :job_template

    has_many :dynamic_fields
    has_many :documents, order: "created_at DESC"
    has_many :job_notes, order: "created_at DESC"

    has_many :job_memberships, foreign_key: "job_id"
    has_many :participants, through: :job_memberships, source: :user
    has_many :unique_participants, through: :job_memberships, source: :user, uniq: true

    has_many :job_processes, order: "created_at DESC"


    searchable do
        text :field_name, :as => :code_textp do
            field.name
        end
        text :well_name, :as => :code_textp do
            well.name
        end
        text :product_line_name, :as => :code_textp do
            job_template.product_line.name
        end
        text :job_template_name, :as => :code_textp do
            job_template.name
        end

        text :district_name, :as => :code_textp do
            district.name
        end

        text :client_name, :as => :code_textp do
            client.name
        end

        text :dynamic_fields_value do
            dynamic_fields.map { |df| df.value }
        end

        time :created_at
        time :updated_at
        integer :company_id
    end


    def add_user!(user, role)

        membership = job_memberships.new
        membership.job_role_id = role
        membership.user = user
        membership.job = self
        membership.save
    end

    def remove_user!(user)
        user = job_memberships.find_by_user_id(user.id)
        if user.present?
            user.destroy
        end
    end

    def self.from_company(company)
        where("jobs.company_id = :company_id", company_id: company.id).order("jobs.created_at DESC")
    end

    def self.from_field(field)
        where("jobs.field_id = :field_id", field_id: field.id).order("jobs.created_at DESC")
    end

    def self.from_district(district)
        where("jobs.district_id = :district_id", district_id: district.id).order("jobs.created_at DESC")
    end

    def self.from_client(client)
        where("jobs.client_id = :client_id", client_id: client.id).order("jobs.created_at DESC")
    end

    def self.search(options, company)
        Sunspot.search(Job) do
            fulltext options[:search]
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end

    def self.advanced_search(query, company)

        conditions = []
=begin
        Sunspot.search(Job) do
            fulltext options[:search]
            with(:company_id, company.id)
            constraints.each do |c|
                with(:created_at).greater_than(Time.now)
            end
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
=end

        ar_query = where(:company_id => company.id)


        query.constraints.each do |constraint|
            operator = "="
            if constraint.operator == "2"
                operator = "<"
            elsif constraint.operator == "3"
                operator = ">"
            end

            if constraint.data_type == "2"
                ar_query = ar_query.where(:dynamic_fields => {:dynamic_field_template_id => constraint.field}).includes(:dynamic_fields)
                ar_query = ar_query.where("dynamic_fields.value " + operator + " :dynamic_field_value", dynamic_field_value: constraint.value).includes(:dynamic_fields)
            else
                ar_query = ar_query.where("wells." + constraint.field + " " + operator + " :well_value", well_value: constraint.value).includes(:well)
            end
        end

        #conditions = ( conditions.empty? ? nil : [conditions.transpose.first.join(' AND '), *conditions.transpose.last] )


        #where(:dynamic_fields => {:dynamic_field_template_id => "8"}).includes(:dynamic_fields)

        return ar_query
    end

    def pre_job_data_good
        self.documents.each do |document|
            if document.category == "Pre-Job" && (document.url.nil? || document.url.empty?)
                return false
            end
        end

        self.dynamic_fields.each do |df|
            if df.value.nil? || df.value.empty?
                return false
            end
        end

        true
    end

    def post_job_data_good
        self.documents.each do |document|
            if document.category == "Post-Job" && (document.url.nil? || document.url.empty?)
                return false
            end
        end

        true
    end

    def supervisor
        membership = self.job_memberships.find { |jm| jm.job_role_id == JobMembership::SUPERVISOR }
        if !membership.nil?
            return membership.user
        end
        nil
    end

    def creator
        membership = self.job_memberships.find { |jm| jm.job_role_id == JobMembership::CREATOR }
        if !membership.nil?
            return membership.user
        end
        nil
    end

    def sent_pre_job_ready_email
        !self.job_processes.find { |jp| jp.event_type == JobProcess::PRE_JOB_DATA_READY }.nil?
    end

    def sent_post_job_ready_email
        !self.job_processes.find { |jp| jp.event_type == JobProcess::POST_JOB_DATA_READY }.nil?
    end

    def approved_to_ship
        !self.job_processes.find { |jp| jp.event_type == JobProcess::APPROVED_TO_SHIP }.nil?
    end

    def approved_to_close
        !self.job_processes.find { |jp| jp.event_type == JobProcess::APPROVED_TO_CLOSE }.nil?
    end

end
