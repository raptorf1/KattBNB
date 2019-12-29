class MessageBroadcastJob < ApplicationJob
  queue_as :messages
  def perform(message_id)
    
    message = Message.find_by(id: message_id)
    if message
      ActionCable.server.broadcast("conversations_#{message.conversation.id}_channel", message: message)
    else
      puts("message not found with id: #{message_id}")
    end
  end
end