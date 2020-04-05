class ConversationsChannel < ApplicationCable::Channel

  def subscribed
    if params['conversations_id'] && Conversation.find_by(id: params['conversations_id']) != nil
      stop_all_streams
      stream_from "conversations_#{params['conversations_id']}_channel"
    else
      connection.transmit error: I18n.t('channels.conversations.sub_error')
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def send_message(data)
    conversation = Conversation.find_by(id: data['conversation_id'])
    if conversation.hidden == nil
      send_actions(data, conversation)
    else
      conversation.update_attribute('hidden', nil)
      send_actions(data, conversation)
    end
  end



  private 

  def attach_image(data, message)
    (data['image'] && data['image'].present?) && DecodeImageService.attach_image(data['image'], message.image)
  end

  def send_actions(data, conversation)
    message = Message.create(conversation_id: data['conversation_id'], body: data['body'], user_id: data['user_id'])
    attach_image(data, message)
    if message.errors.present?
      transmit({type: 'errors', data: message.errors.full_messages})
    elsif conversation.user1_id == data['user_id'] || conversation.user2_id == data['user_id']
      user_sending = User.where(id: message.user_id)
      conversation.user1_id == message.user_id ? user_receiving = User.where(id: conversation.user2_id) : user_receiving = User.where(id: conversation.user1_id)
      MessageBroadcastJob.perform_later(message.id)
      user_receiving[0].message_notification == true && MessagesMailer.notify_user_new_message(user_sending[0], user_receiving[0], message.body).deliver
    else
      message.destroy
      transmit({type: 'errors', data: I18n.t('channels.conversations.message_error')})
    end
  end

end
