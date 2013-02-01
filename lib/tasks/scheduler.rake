task :daily_activity_email => :environment do
    User.all.each do |user|
        if !user.admin?
            activities = Activity.activities_for_user_today(user).select("activities.job_id, activities.created_at").group('activities.job_id, activities.created_at')
            if !activities.nil? and activities.any?
                UserMailer.daily_activity(user, activities).deliver
            end
        end
    end
end