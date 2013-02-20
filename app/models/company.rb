class Company < ActiveRecord::Base
    attr_accessible :name,
                    :address_line_1,
                    :address_line_2,
                    :postal_code,
                    :state,
                    :country,
                    :logo,
                    :logo_large,
                    :phone_number,
                    :support_email,
                    :website,
                    :vpn_range

    validates :name, presence: true, uniqueness: true, length: {maximum: 50}

    has_many :users, dependent: :destroy
    has_many :roles, dependent: :destroy, class_name: "UserRole"
    has_many :districts, dependent: :destroy
    has_many :clients, dependent: :destroy
    has_many :fields, dependent: :destroy
    has_many :wells, dependent: :destroy
    has_many :divisions, dependent: :destroy
    has_many :segments, dependent: :destroy
    has_many :product_lines, dependent: :destroy
    has_many :job_templates, dependent: :destroy

    has_many :activities

    belongs_to :admin

end
