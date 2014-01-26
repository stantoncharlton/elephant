class Job < ActiveRecord::Base
    attr_accessible :start_date,
                    :end_date,
                    :close_date,
                    :status,
                    :rating,
                    :job_number,
                    :api_number,
                    :inventory_notes,
                    :inventory_confirmed

    include PostJobReportHelper
    acts_as_xlsx

    after_commit :flush_cache

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :client
    validates_presence_of :district
    validates_presence_of :field
    validates_presence_of :well
    validates_presence_of :job_template

    validates :inventory_notes, length: {maximum: 500}

    belongs_to :company
    belongs_to :client
    belongs_to :district
    belongs_to :field
    belongs_to :well
    belongs_to :job_template

    has_many :dynamic_fields, dependent: :destroy, order: "ordering ASC"
    has_many :documents, dependent: :destroy, order: "ordering ASC"
    has_many :job_notes, dependent: :destroy, order: "created_at DESC"

    has_many :job_memberships, dependent: :destroy, foreign_key: "job_id", order: "created_at ASC"
    has_many :participants, through: :job_memberships, source: :user
    has_many :unique_participants, through: :job_memberships, source: :user, uniq: true

    has_many :secondary_tools, dependent: :destroy

    has_many :issues, order: "failure_at DESC"
    has_many :alerts, dependent: :destroy

    has_many :document_shares, order: "created_at DESC"

    has_many :part_memberships, order: "name ASC", dependent: :destroy, foreign_key: "job_id"

    has_many :job_times, dependent: :destroy

    has_many :inbound_shipments, class_name: "Shipment", foreign_key: "to_id"
    has_many :outbound_shipments, class_name: "Shipment", foreign_key: "from_id"

    ACTIVE = 1

    PRE_JOB = 5
    ON_JOB = 6
    POST_JOB = 7


    COMPLETE = 50

    ABANDONED = 100


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
        text :segment_name, :as => :code_textp do
            job_template.product_line.segment.name
        end
        text :division_name, :as => :code_textp do
            job_template.product_line.segment.division.name
        end
        text :job_template_name, :as => :code_textp do
            job_template.name
        end

        text :district_name, :as => :code_textp do
            district.present? ? district.name : ""
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
        integer :master_district_id do
            district.present? ? district.master_district_id : -1
        end

        integer :job_membership, :multiple => true do
            unique_participants.map { |u| u.id }
        end
    end

    def absolute_url
        "https://www.elephant-cloud.com/jobs/" + self.id.to_s
    end

    def active
        self.status >= 1 && self.status < 50
    end

    def add_user!(user, role)

        membership = job_memberships.new
        membership.company = user.company
        membership.job_role_id = role
        membership.user = user
        membership.user_name = user.name
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

    def self.search(user, options, company, pagination = true)
        paginate_count = pagination ? 10 : 100000000
        Sunspot.search(Job) do
            fulltext options[:search]
            any_of do
                if user.role.limit_to_assigned_jobs?
                    with(:job_membership, user.id)
                elsif user.role.limit_to_district? && user.district.present?
                    with(:master_district_id, user.district.master_district_id)
                elsif user.role.limit_to_product_line? && !user.product_line.nil?
                    with(:product_line_id, user.product_line.id)
                end
            end
            with(:company_id, company.id)
            order_by :created_at, :desc
            paginate :page => options[:page], :per_page => paginate_count
        end
    end

    def self.advanced_search(query, company)

        ar_query = where(:company_id => company.id)

        if query.user.role.limit_to_district?
            where("jobs.district_id IN (SELECT id FROM districts where master_district_id = :district_id)", district_id: query.user.district.master_district_id)
            #where(:district_id => query.user.district.id)
        elsif query.user.role.limit_to_product_line? && !query.user.product_line.nil?
            where(:product_line_id => query.user.product_line.id)
        end

        districts_consolidated = false
        clients_consolidated = false

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

            if constraint.data_type == 2
                ar_query = ar_query.where(:dynamic_fields => {:dynamic_field_template_id => constraint.field}).includes(:dynamic_fields)
                if constraint.operator == "1" or constraint.operator == "2" or constraint.operator == "3"
                    new_value = DynamicField.new.convert(value, constraint.units, DynamicField.new.get_storage_value_type(constraint.units)).to_f
                    puts value.to_s + " / " + new_value.to_s + " / " + constraint.units + "  .............."
                    if constraint.operator == "1"
                        ar_query = ar_query.where("CAST(dynamic_fields.value as decimal) >= :lower_end AND CAST(dynamic_fields.value as decimal) <= :higher_end", lower_end: new_value.round(1), higher_end: (new_value.round(3) + 0.001)).includes(:dynamic_fields)
                    else
                        ar_query = ar_query.where("CAST(dynamic_fields.value as decimal) " + operator + " :dynamic_field_value", dynamic_field_value: new_value).includes(:dynamic_fields)
                    end

                else
                    ar_query = ar_query.where("dynamic_fields.value " + operator + " :dynamic_field_value", dynamic_field_value: value).includes(:dynamic_fields)
                end
            elsif constraint.data_type == 3
                if !clients_consolidated
                    clients_query = nil
                    query.constraints.each do |c|
                        if c.data_type == 3
                            if !clients_query.nil?
                                clients_query += "OR jobs.client_id = " + c.client_id
                            else
                                clients_query = "jobs.client_id = " + c.client_id
                            end
                        end
                    end
                    ar_query = ar_query.where(clients_query)
                    clients_consolidated
                end
            elsif constraint.data_type == 4
                if !districts_consolidated
                    districts_query = nil
                    query.constraints.each do |c|
                        if c.data_type == 4
                            if !districts_query.nil?
                                districts_query += "OR jobs.district_id = " + c.district_id
                            else
                                districts_query = "jobs.district_id = " + c.district_id
                            end
                        end
                    end
                    ar_query = ar_query.where(districts_query)
                    districts_consolidated
                end
            elsif constraint.data_type == 5
                ar_query = ar_query.where("(jobs.job_template_id IN (SELECT job_template_id FROM primary_tools WHERE primary_tools.tool_id = :tool_id)) OR (jobs.id IN (SELECT job_id FROM secondary_tools WHERE secondary_tools.tool_id = :tool_id))", tool_id: constraint.field)
            elsif constraint.data_type == 6
                ar_query = ar_query.where("(jobs.id IN (SELECT failures.job_id FROM failures WHERE failures.failure_master_template_id = :failure_id))", failure_id: constraint.field)
            else
                ar_query = ar_query.where("wells." + constraint.field + " " + operator + " :well_value", well_value: value).includes(:well)
            end
        end

        return ar_query
    end

    def activity
        Activity.activities_for_job(self).includes(:target, :job, :user)
    end

    def recent_activity(recent_date)
        Activity.activities_for_job(self).includes(:target, :job, :user).where("activities.created_at > ?", (recent_date - 1.day))
    end

    def other_jobs
        self.well.jobs.includes(:job_template, :client, :district, :dynamic_fields).select { |j| j != self }
    end

    def notices_documents
        self.documents.includes(:user, :document_template, :job, :document_shares, :document_revisions).where(:category => Document::NOTICES)
    end

    def pre_job_documents
        self.documents.includes(:user, :document_template, :job, :document_shares, :document_revisions).where(:category => Document::PRE_JOB)
    end

    def on_job_documents
        self.documents.includes(:user, :document_template, :job, :document_shares, :document_revisions).where(:category => Document::ON_JOB)
    end

    def post_job_documents
        self.documents.includes(:user, :document_template, :job, :document_shares, :document_revisions).where(:category => Document::POST_JOB)
    end

    def post_job_report_document
        self.documents.includes(:user, :document_template, :job).where(:category => Document::POST_JOB_REPORT).last
    end

    def dynamic_fields_required
        self.dynamic_fields.includes(:dynamic_field_template).where(:optional => false)
    end

    def dynamic_fields_optional
        self.dynamic_fields.includes(:dynamic_field_template).where(:optional => true)
    end

    def get_role(role)
        membership = self.job_memberships.includes(:user, :job).find { |jm| jm.job_role_id == role.to_i }
        if !membership.nil?
            return membership.user
        end
        nil
    end

    def get_membership_role(user)
        return nil unless user.present?
        roles = self.job_memberships.to_a.select { |jm| jm.user_id == user.id }
        if roles.length > 0
            roles.find { |jm| jm.job_role_id != JobMembership::CREATOR }
        else
            roles[0]
        end
    end

    def is_coordinator_or_creator?(user)
        user == self.get_role(JobMembership::COORDINATOR) || user == self.get_role(JobMembership::MANAGER) || user == self.get_role(JobMembership::CREATOR)
    end

    def duration
        [((self.close_date.present? ? self.close_date : Date.now) - (self.start_date.present? ? self.start_date : self.created_at)).to_i / (24 * 60 * 60), 0].max
    end

    def status_string
        case self.status
            when PRE_JOB
                "Pre Job"
            when ON_JOB
                "On Job"
            when POST_JOB
                "Post Job"
            when COMPLETE
                "Complete"
            when ABANDONED
                "Abandoned"
            else
                ""
        end
    end

    def status_percentage
        Rails.cache.fetch([self.class.name, self.id.to_s + '-sp'], expires_in: 30.days) do
            percentage = 100
            current = 0

            pre_job_docs = self.pre_job_documents.count
            fields = self.dynamic_fields.select { |df| !df.predefined? && !df.optional? }.count

            if pre_job_docs > 0
                pre_doc_value = (fields == 0 ? 50 : 35) / pre_job_docs.to_f
            end
            if fields > 0
                fields_value = (pre_job_docs == 0 ? 50 : 15) / fields.to_f
            end

            current += (self.pre_job_documents.select { |document| !document.url.blank? }.count || 0) * pre_doc_value.to_f
            current += (self.dynamic_fields.select { |df| !df.predefined? && !df.optional? && !df.value.blank? }.count || 0) * fields_value.to_f


            if self.status >= Job::ON_JOB
                if self.post_job_documents.count > 0
                    post_doc_value = 50 / self.post_job_documents.count.to_f
                    current += (self.post_job_documents.select { |document| !document.url.blank? }.count || 0) * post_doc_value.to_f
                else
                    current += 50
                end
            end

            current
        end
    end


    def flush_cache_status_percentage
        Rails.cache.delete([self.class.name, self.id.to_s + '-sp'])
    end

    def user_is_member?(user)
        return false if user.nil?
        job_memberships = self.job_memberships.to_a
        return job_memberships.select { |jm| jm.user_id == user.id }.any?
    end

    def closed
        return self.status == Job::COMPLETE || self.status == Job::ABANDONED
    end

    def is_job_editable?(user)
        return false if self.status == Job::COMPLETE
        return true if self.user_is_member?(user)
        return true if user.role.global_edit?
        return true if user.role.district_edit? && user.district.present? && self.district.master_district_id == user.district.master_district_id

        false
    end

    def can_user_view?(user)
        return true if user.role.global_read?
        return true if self.user_is_member?(user)
        return true if user.role.district_read? && user.district.present? && self.district.master_district_id == user.district.master_district_id

        false
    end

    def ship_job(user)

        Activity.add(user, Activity::JOB_APPROVED_TO_SHIP, self, nil, self)


        self.unique_participants.each do |participant|
            participant.send_job_shipping_email(self)
            Alert.add(participant, Alert::JOB_SHIPPED, self, user, self)
        end

        Alert.where("alerts.alert_type = :alert_type AND alerts.job_id = :job_id",
                    alert_type: Alert::PRE_JOB_DATA_READY,
                    job_id: self.id).each { |a| a.destroy }
    end

    def begin_on_job
        self.update_attribute(:status, Job::ON_JOB)
        self.part_memberships.each do |part_membership|
            if part_membership.part_type == PartMembership::INVENTORY && part_membership.part.present?
                part_membership.part.current_job = self
                part_membership.part.status = Part::ON_JOB
                part_membership.part.save
            end
        end
    end

    def close_job(user)

        self.status = Job::COMPLETE
        self.close_date = DateTime.now
        self.save

        user.alerts.where("alerts.alert_type = :alert_type AND alerts.job_id = :job_id",
                          alert_type: Alert::POST_JOB_DATA_READY,
                          job_id: self.id).each { |a| a.destroy }

        Activity.add(user, Activity::JOB_APPROVED_TO_CLOSE, self, nil, self)


        self.part_memberships.each do |part_membership|
            if part_membership.part_type == PartMembership::INVENTORY && part_membership.part.present?
                if part_membership.part.status == Part::ON_JOB && part_membership.part.current_job == self
                    part_membership.part.current_job = nil
                    part_membership.part.status = Part::AVAILABLE
                    part_membership.part.save
                end
            end
        end

        #self.unique_participants.each do |participant|
        #    participant.send_job_completed_email(self)
        #    Alert.add(participant, Alert::JOB_CLOSED, self, user, self)
        #end

        #if self.documents.any?
        #    self.generate_post_job_report
        #end

    end

    def prepare_post_job_report
        document = Document.new(template: false, read_only: true)
        document.job = self
        document.company = self.company
        document.category = Document::POST_JOB_REPORT
        document.name = "#{self.id} - PostJobReport.pdf"
        document.save
    end

    def generate_post_job_report
        if self.documents.any?
            if post_job_report_document.nil?
                self.prepare_post_job_report
            end
            job_documents = self.documents.to_a
            documents = []
            self.job_template.post_job_report_documents.each do |post_job_report_document|
                document = job_documents.find { |d| d.document_template_id == post_job_report_document.document.id }
                if document != nil
                    if document.document_type == Document::DOCUMENT
                        if !document.url.blank?
                            documents << document
                        elsif document.document_template.present? && !document.document_template.url.blank?
                            documents << document.document_template
                        end
                    elsif document.document_type == Document::JOB_LOG
                        documents << document
                    elsif document.document_type == Document::CUSTOM_DATA
                        documents << document
                    end
                end
            end
            if !job_documents.any?
                documents = job_documents.select { |d| !d.url.blank? }
            end

            merge self, documents
        end
    end

    def transfer_assets job
        PartMembership.transaction do
            self.part_memberships.each do |p|
                if !p.shipping
                    @part_membership = p.duplicate
                    @part_membership.job = job
                    @part_membership.save
                end
            end
        end
    end

    def drilling_log
        DrillingLog.joins(:job).where("jobs.well_id = ?", self.well_id).first
    end

    def well_plan
        Survey.joins(document: :job).where("jobs.well_id = ?", self.well_id).where(:plan => true).first
    end

    def survey
        Survey.joins(document: :job).where("jobs.well_id = ?", self.well_id).where(:plan => false).first
    end

    def self.include_models(jobs)
        jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).includes(:job_memberships).includes(well: :rig)
    end

    def self.cached_find(id)
        Rails.cache.fetch([name, id], expires_in: 10.minutes) { find(id) }
    end

    def flush_cache
        Rails.cache.delete([self.class.name, id])
    end

end
