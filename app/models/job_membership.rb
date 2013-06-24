class JobMembership < ActiveRecord::Base
    attr_accessible :job_role_id,
                    :user_name

    after_save :after_save
    after_destroy :after_destroy

    belongs_to :user
    belongs_to :job

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
           else
               "-"
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
