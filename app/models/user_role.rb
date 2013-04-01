class UserRole < ActiveRecord::Base
    attr_accessible :role_id

    validates :title, presence: true, length: {maximum: 50}, uniqueness: {case_sensitive: false, scope: :company_id}
    validates_presence_of :company

    belongs_to :company

    # Admin
    ROLE_ELEPHANT_ADMIN = 1

    # Sales
    ROLE_SALES_ENGINEER = 10
    ROLE_APPLICATION_ENGINEER = 11
    ROLE_DESIGN_ENGINEER = 12
    ROLE_IN_HOUSE_ENGINEER = 13
    ROLE_BUSINESS_ENGINEER = 14
    ROLE_ENGINEER = 15

    # Field
    ROLE_DISTRICT_MANAGER = 20
    ROLE_LOCAL_ENGINEER_MANAGER = 21
    ROLE_INVENTORY_MANAGER = 22
    ROLE_FIELD_ENGINEER = 30
    ROLE_FIELD_SPECIALIST = 31
    ROLE_OPERATIONS_COORDINATOR = 32
    ROLE_WAREHOUSE_SPECIALIST = 33
    ROLE_ADMINISTRATOR = 34
    ROLE_FIELD_ENGINEER_TRAINEE = 35
    ROLE_FIELD_SPECIALIST_TRAINEE = 36

    # Support
    ROLE_CORPORATE_MANAGER = 50
    ROLE_RELIABILITY_MANAGER = 51
    ROLE_GENERAL_MANAGER = 52
    ROLE_PRODUCT_LINE_MANAGER = 53
    ROLE_ENGINEERING_MANAGER = 54
    ROLE_DESIGN_MANAGER = 55
    ROLE_APP_SUPPORT_ENGINEER = 56
    ROLE_SUPPORT = 57


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("title ASC")
    end

    def title
        existing_role = UserRole.where("company_id = :company_id AND role_id = :role_id", company_id: self.company.id, role_id: self.role_id).limit(1).first
        return existing_role.read_attribute(:title) unless existing_role.nil? || existing_role.read_attribute(:title).blank?

        case self.role_id
            when ROLE_ELEPHANT_ADMIN
                "Elephant Administrator"

            # Sales
            when ROLE_SALES_ENGINEER
                "Sales Engineer"
            when ROLE_APPLICATION_ENGINEER
                "Application Engineer"
            when ROLE_DESIGN_ENGINEER
                "Design Engineer"
            when ROLE_IN_HOUSE_ENGINEER
                "In-house Engineer"
            when ROLE_BUSINESS_ENGINEER
                "Business Engineer"
            when ROLE_ENGINEER
                "Engineer"

            # Field
            when ROLE_DISTRICT_MANAGER
                "District Manager"
            when ROLE_LOCAL_ENGINEER_MANAGER
                "Local Engineer Manager"
            when ROLE_INVENTORY_MANAGER
                "Inventory Manager"
            when ROLE_FIELD_ENGINEER
                "Field Engineer"
            when ROLE_FIELD_SPECIALIST
                "Field Specialist"
            when ROLE_OPERATIONS_COORDINATOR
                "Operations Coordinator"
            when ROLE_WAREHOUSE_SPECIALIST
                "Warehouse Specialist"
            when ROLE_ADMINISTRATOR
                "Administrator"
            when ROLE_FIELD_ENGINEER_TRAINEE
                "Field Engineer Trainee"
            when ROLE_FIELD_SPECIALIST_TRAINEE
                "Field Specialist Trainee"

            # Support
            when ROLE_CORPORATE_MANAGER
                "Corporate Manager"
            when ROLE_RELIABILITY_MANAGER
                "Reliability Manager"
            when ROLE_GENERAL_MANAGER
                "General Manager"
            when ROLE_PRODUCT_LINE_MANAGER
                "Product Line Manager"
            when ROLE_ENGINEERING_MANAGER
                "Engineer Manager"
            when ROLE_DESIGN_MANAGER
                "Design Manager"
            when ROLE_APP_SUPPORT_ENGINEER
                "Application Support Engineer"
            when ROLE_SUPPORT
                "Support"
        end
    end

    def self.from_user(user)
        UserRole.from_role user.role_id, user.company
    end

    def self.from_role(role_id, company)
        user_role = UserRole.new(role_id: role_id.blank? ? ROLE_SUPPORT : role_id.to_i)
        user_role.company = company
        user_role
    end

    def self.sales_roles(company)
        roles = []
        roles << UserRole.from_role(ROLE_SALES_ENGINEER, company)
        roles << UserRole.from_role(ROLE_APPLICATION_ENGINEER, company)
        roles << UserRole.from_role(ROLE_DESIGN_ENGINEER, company)
        roles << UserRole.from_role(ROLE_IN_HOUSE_ENGINEER, company)
        roles << UserRole.from_role(ROLE_BUSINESS_ENGINEER, company)
        roles << UserRole.from_role(ROLE_ENGINEER, company)
        roles
    end

    def self.field_roles(company)
        roles = []
        roles << UserRole.from_role(ROLE_DISTRICT_MANAGER, company)
        roles << UserRole.from_role(ROLE_LOCAL_ENGINEER_MANAGER, company)
        roles << UserRole.from_role(ROLE_INVENTORY_MANAGER, company)
        roles << UserRole.from_role(ROLE_FIELD_ENGINEER, company)
        roles << UserRole.from_role(ROLE_FIELD_SPECIALIST, company)
        roles << UserRole.from_role(ROLE_OPERATIONS_COORDINATOR, company)
        roles << UserRole.from_role(ROLE_WAREHOUSE_SPECIALIST, company)
        roles << UserRole.from_role(ROLE_ADMINISTRATOR, company)
        roles << UserRole.from_role(ROLE_FIELD_ENGINEER_TRAINEE, company)
        roles << UserRole.from_role(ROLE_FIELD_SPECIALIST_TRAINEE, company)
        roles
    end

    def self.support_roles(company)
        roles = []
        roles << UserRole.from_role(ROLE_CORPORATE_MANAGER, company)
        roles << UserRole.from_role(ROLE_RELIABILITY_MANAGER, company)
        roles << UserRole.from_role(ROLE_GENERAL_MANAGER, company)
        roles << UserRole.from_role(ROLE_PRODUCT_LINE_MANAGER, company)
        roles << UserRole.from_role(ROLE_ENGINEERING_MANAGER, company)
        roles << UserRole.from_role(ROLE_DESIGN_MANAGER, company)
        roles << UserRole.from_role(ROLE_APP_SUPPORT_ENGINEER, company)
        roles << UserRole.from_role(ROLE_SUPPORT, company)
        roles
    end

    def self.admin_roles(company)
        roles = []
        roles << UserRole.from_role(ROLE_ELEPHANT_ADMIN, company)
        roles
    end

    def self.all_roles(company)
        roles = []
        UserRole.support_roles(company).each do |role|
            roles << role
        end
        UserRole.field_roles(company).each do |role|
            roles << role
        end
        UserRole.sales_roles(company).each do |role|
            roles << role
        end
        UserRole.admin_roles(company).each do |role|
            roles << role
        end
        roles
    end

    def global_read?
        return true if self.role_id >= 1 && self.role_id <= 19
        return true if self.role_id == ROLE_DISTRICT_MANAGER || self.role_id == ROLE_LOCAL_ENGINEER_MANAGER || self.role_id == ROLE_INVENTORY_MANAGER
        return true if self.role_id >= 50

        false
    end

    def district_read?
        global_read? || self.role_id == ROLE_OPERATIONS_COORDINATOR || self.role_id == ROLE_ADMINISTRATOR
    end

    def limit_to_district?
        self.role_id >= 30 && self.role_id <= 39
    end

    def limit_to_product_line?
        self.role_id >= 20 && self.role_id <= 29
    end

    def no_assigned_jobs?
        (self.role_id >= 50 && self.role_id <= 59) || self.role_id == 1
    end

end
