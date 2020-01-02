class ConversationsChannel < ApplicationCable::Channel

  def subscribed
    if params['conversations_id'] && Conversation.find_by(id: params['conversations_id']) != nil
      stop_all_streams
      stream_from "conversations_#{params['conversations_id']}_channel"
    else
      connection.transmit error: 'No conversation specified or conversation does not exist. Connection rejected!'
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def send_message(data)
    conversation = Conversation.find_by(id: data['conversation_id'])
    message = Message.create(conversation_id: data['conversation_id'], body: data['body'], user_id: data['user_id'])
    if message.errors.present?
      transmit({type: 'errors', data: message.errors.full_messages})
    elsif conversation.user1_id != data['user_id'] || conversation.user2_id != data['user_id']
      message.destroy
      transmit({type: 'errors', data: 'You cannot send message to a conversation you are not part of!'})
    else
      MessageBroadcastJob.perform_later(message.id)
    end
  end

end
