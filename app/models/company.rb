class Company < ActiveRecord::Base
    attr_accessible :address_line_1, :address_line_2, :admin_id, :country, :logo,
                    :logo_large, :name, :phone_number, :postal_code, :state,
                    :support_email, :website

    validates :name, presence: true, uniqueness: true, length: {maximum: 50}

end
