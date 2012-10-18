ActionMailer::Base.smtp_settings = {
        :address              => "smtp.gmail.com",
        :port                 => 587,
        :domain               => "go-elephant.herokuapp.com",
        :user_name            => "ryan.dawson.thirteen23@gmail.com",
        :password             => "elephant!3",
        :authentication       => "plain",
        :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "heroku.com" if Rails.env.production?
ActionMailer::Base.default_url_options[:host] = "localhost:3000" if Rails.env.development?
#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?