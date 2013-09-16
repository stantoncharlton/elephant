class JobMembership < ActiveRecord::Base
    attr_accessible :job_role_id,
                    :user_name

    acts_as_tenant(:company)

    after_save :after_save
    after_destroy :after_destroy

    belongs_to :user
    belongs_to :job
    belongs_to :company

    validates :user, presence: true
    validates :job, presence: true

    #validates_uniqueness_of :user_id, scope: :job_id

    validates :job_role_id, presence: true


    OBSERVER = 1
    MANAGER = 2
    COORDINATOR = 3
    FIELD = 4
    SHOP = 5
    CREATOR = 6
    TOOL_COORDINATOR = 7


    def role_title
       case self.job_role_id
           when OBSERVER
               "Observer"
           when MANAGER
               "Manager"
           when COORDINATOR
               "Coordinator"
           when FIELD
               "Field"
           when SHOP
               "Shop"
           when CREATOR
               "Creator"
           when TOOL_COORDINATOR
               "Tool Coordinator"
           else
               "-"
       end
    end

    def icon_css_style
        case self.job_role_id
            when OBSERVER
                ""
            when MANAGER
                "member-icon-manager"
            when COORDINATOR
                "member-icon-coordinator"
            when FIELD
                "member-icon-field"
            when SHOP
                "member-icon-shop"
            when TOOL_COORDINATOR
                "member-icon-tool-coordinator"
            when CREATOR
                ""
            else
                ""
        end
    end

    def icon_image_css_style
        case self.job_role_id
            when OBSERVER
                ""
            when MANAGER
                "member-icon-image-manager"
            when COORDINATOR
                "member-icon-image-coordinator"
            when FIELD
                "member-icon-image-field"
            when SHOP
                "member-icon-image-shop"
            when TOOL_COORDINATOR
                "member-icon-image-coordinator"
            when CREATOR
                "member-icon-image-manager"
            else
                ""
        end
    end

private
    def after_save
        update_counter_cache
    end

    def after_destroy
        update_counter_cache
    end

    def update_counter_cache
        self.job.job_memberships_count = self.job.job_memberships.where("job_memberships.job_role_id != 6").count()
        self.job.save
    end

end
