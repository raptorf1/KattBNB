class MessagesMailer < ApplicationMailer

  def notify_user_new_message(user1, user2)
    @user1 = user1
    @user2 = user2

    mail(to: @user2.email, subject: "New message from #{@user1.nickname}!")
  end

end
