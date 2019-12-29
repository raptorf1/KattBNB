class MessageBroadcastJob < ApplicationJob
  queue_as :messages
  def perform(message_id)
    message = Message.find_by(id: message_id)
    if message
      serialized_message = MessagesSerializer.new(message).as_json
      ActionCable.server.broadcast("conversations_#{message.conversation.id}_channel", message: serialized_message)
    else
      puts("message not found with id: #{message_id}")
    end
  end
end