class MessagesMailer < ApplicationMailer

  def notify_user_new_message(user1, user2, message)
    @user1 = user1
    @user2 = user2

    message == '' ? @message = I18n.t('serializers.conversations.index.image_attachment') : message.length > 100 ? @message = message.slice(0,100)+'...' : @message = message

    I18n.with_locale(@user2.lang_pref) do
      mail(to: @user2.email, subject: I18n.t('mailers.messages.notify_user_new_message', user: @user1.nickname))
    end
  end

end
