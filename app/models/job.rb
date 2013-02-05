class Job < ActiveRecord::Base
    attr_accessible :client_contact_name,
                    :start_date,
                    :end_date,
                    :active


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
        integer :client_id
        integer :field_id
        integer :district_id
        integer :job_template_id
        integer :product_line_id do
            job_template.product_line.id
        end
        integer :segment_id do
            job_template.product_line.segment.id
        end
        integer :division_id do
            job_template.product_line.segment.division.id
        end

        integer :job_membership, :multiple => true do
            unique_participants.map { |u| u.id }
        end
    end

    def absolute_url
        "https://www.go-elephant.com/jobs/" + self.id.to_s
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

    def self.search(user, options, company)

        Sunspot.search(Job) do
            fulltext options[:search]
            any_of do
                with(:job_membership, user.id)
                if user.role.district_read?
                    with(:district_id, user.district.id)
                end
                if user.role.product_line_read? and !user.product_line.nil?
                    with(:product_line_id, user.product_line.id)
                end
            end
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end

    def self.advanced_search(query, company)

        ar_query = where(:company_id => company.id)

        query.constraints.each do |constraint|
            operator = "="
            value = constraint.value

            if constraint.operator == "2"
                operator = "<="
            elsif constraint.operator == "3"
                operator = ">="
            elsif constraint.operator == "4"
                operator = "t"
            elsif constraint.operator == "5"
                operator = "f"
            elsif constraint.operator == "6"
                operator = "LIKE"
            end

            if constraint.data_type == "2"
                ar_query = ar_query.where(:dynamic_fields => {:dynamic_field_template_id => constraint.field}).includes(:dynamic_fields)
                if constraint.operator == "1" or constraint.operator == "2" or constraint.operator == "3"
                    ar_query = ar_query.where("CAST(dynamic_fields.value as INT) " + operator + " :dynamic_field_value", dynamic_field_value: value).includes(:dynamic_fields)
                else
                    ar_query = ar_query.where("dynamic_fields.value " + operator + " :dynamic_field_value", dynamic_field_value: value).includes(:dynamic_fields)
                end
            else
                ar_query = ar_query.where("wells." + constraint.field + " " + operator + " :well_value", well_value: value).includes(:well)
            end
        end

        return ar_query
    end

    def activity
        Activity.activities_for_job(self)
    end

    def recent_activity(recent_date)
        Activity.activities_for_job(self).where("activities.created_at > ?", (recent_date - 1.day))
    end

    def other_jobs
        self.well.jobs.select { |j| j != self }
    end

    def notices_documents
        self.documents.select { |document| document.category == Document::NOTICES }.sort_by { |e| e.order || 0 }
    end

    def pre_job_documents
        self.documents.select { |document| document.category == Document::PRE_JOB }.sort_by { |e| e.order || 0 }
    end

    def post_job_documents
        self.documents.select { |document| document.category == Document::POST_JOB }.sort_by { |e| e.order || 0 }
    end

    def pre_job_data_good
        self.pre_job_documents.each do |document|
            if document.url.blank?
                return false
            end
        end

        self.dynamic_fields.each do |df|
            if df.value.blank?
                return false
            end
        end

        true
    end

    def post_job_data_good
        self.post_job_documents.each do |document|
            if document.url.blank?
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

    def status
        if self.approved_to_close
            I18n.t("jobs.job_data.status_complete")
        elsif self.approved_to_ship and self.sent_post_job_ready_email
            I18n.t("jobs.job_data.status_post_job")
        elsif self.approved_to_ship
            I18n.t("jobs.job_data.status_in_field")
        else
            I18n.t("jobs.job_data.status_pre_job")
        end
    end

    def status_percentage
        percentage = 100
        current = 0
        pre_job_docs = self.pre_job_documents.count
        fields = self.dynamic_fields.count

        if pre_job_docs > 0
            pre_doc_value = (fields == 0 ? 50 : 35) / pre_job_docs
        end
        if fields > 0
            fields_value = (pre_job_docs == 0 ? 50 : 15) / fields
        end

        current += (self.pre_job_documents.select { |document| !document.url.blank? }.count || 0) * pre_doc_value.to_f
        current += (self.dynamic_fields.select { |df| !df.value.blank? }.count || 0) * fields_value.to_f

        if self.approved_to_ship
            if self.post_job_documents.count > 0
               post_doc_value = 50 / self.post_job_documents.count
               current +=  (self.post_job_documents.select { |document| !document.url.blank? }.count || 0) * post_doc_value.to_f
            else
                current += 50
            end
        end

        current
    end

    def user_is_member?(user)
        !self.job_memberships.find { |jm| jm.user == user }.nil?
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

    def is_job_editable?(user)

        if !self.user_is_member?(user)
            if !user.role.district_modify? and self.district == user.district
                return false

            elsif !user.role.product_line_modify? and !user.product_line.nil? and self.job_template.product_line == user.product_line
                return false
            end
        end

        !self.approved_to_close
    end

    def can_user_view?(user)
        if user.role.global_read?
            return true
        end

        if !self.user_is_member?(user)

            if user.role.district_read? and self.district == user.district
                return true
            elsif user.role.product_line_read? and !user.product_line.nil? and self.job_template.product_line == user.product_line
                return true
            end
        else
            return true
        end

        false
    end

end
