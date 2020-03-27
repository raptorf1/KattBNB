class ConversationsMailer < ApplicationMailer

  def notify_user_new_conversation(user1, user2)
    @user1 = user1
    @user2 = user2

    mail(to: @user2.email, subject: I18n.t('mailers.conversations.notify_user_new_conversation', user: @user1.nickname))
  end

end
