class UserObserver < ActiveRecord::Observer
    cattr_accessor :current_user

    def after_create(user)
        Activity.add(self.current_user, Activity::USER_CREATED, user)
    end

    def after_commit(user)
        Activity.add(self.current_user, Activity::USER_UPDATED, user)
    end

    def after_destroy(user)
        Activity.add(self.current_user, Activity::USER_DESTROYED, user)
    end
end
