class ConversationsMailer < ApplicationMailer

  def notify_user_new_conversation(user1, user2)
    @user1 = user1
    @user2 = user2

    mail(to: @user2.email, subject: "#{@user1.nickname} started a conversation with you!")
  end

end
