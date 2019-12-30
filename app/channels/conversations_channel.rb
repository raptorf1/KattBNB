class ConversationsChannel < ApplicationCable::Channel

  def subscribed
    stop_all_streams
    stream_from "conversations_#{params['conversations_id']}_channel"
  end

  def unsubscribed
    stop_all_streams
  end

  def send_message(data)
    message = Message.create(conversation_id: data['conversation_id'], body: data['body'], user_id: data['user_id'])
    if message.errors.present?
      transmit({type: 'errors', data: message.errors.full_messages})
    else
      MessageBroadcastJob.perform_later(message.id)
    end
  end
end
