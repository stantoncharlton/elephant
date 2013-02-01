class UserMailer < ActionMailer::Base
  default from: "Elephant <no-reply@go-elephant.com>"

  def registration_confirmation(user, password)
      @user = user
      @password = password
      mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
           :subject => "#{@user.company.name} Added you to Elephant")
  end

  def reset_password(user, password)
      @user = user
      @password = password
      mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
           :subject => "Your Elephant New Password")
  end


  def daily_activity(user, activities)
      @user = user
      @activities = activities
      mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
           :subject => "Elephant Daily Job Activity")
  end

end
