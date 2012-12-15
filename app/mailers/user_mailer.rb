class UserMailer < ActionMailer::Base
  default from: "system@go-elephant.com"

  def registration_confirmation(user)
      @user = user
      mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
           :subject => "#{@user.company.name} added you to Elephant")
  end

  def reset_password(user, password)
      @user = user
      @password = password
      mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
           :subject => "Your Elephant new password")
  end
end
