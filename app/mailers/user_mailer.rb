class UserMailer < ActionMailer::Base
  default from: "system@go-elephant.com"

  def registration_confirmation(user)
      @user = user
      mail(:to => "ryan@thirteen23.com", :subject => "#{@user.company.name} added you to Elephant")
  end
end
