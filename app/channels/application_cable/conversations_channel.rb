class ConversationsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "conversations_#{params['conversations_id']}_channel"
  end

  def unsubscribed
    stop_all_streams
  end

  def send_message(data)
    message = current_api_v1_user.message.create(conversation_id: data['conversation_id'], body: ['body'])
    if message.errors.present?
      transmit({type: 'errors', data: message.errors.full_messages})
    else
      MessageBroadcastJob.perform_later(message.id)
    end
  end
end