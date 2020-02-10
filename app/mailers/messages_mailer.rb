class MessagesMailer < ApplicationMailer

  def notify_user_new_message(user1, user2, message)
    @user1 = user1
    @user2 = user2

    if message.length > 100
      @message = message.slice(0,100)+'...'
    else
      @message = message
    end

    mail(to: @user2.email, subject: "New message from #{@user1.nickname}!")
  end

end
