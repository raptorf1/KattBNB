class MessageBroadcastJob < ApplicationJob
  queue_as :messages

  def perform(message_id)
    message = Message.find(message_id)
    serialized_data = ActiveModelSerializers::Adapter::Json.new(Messages::Serializer.new(message)).serializable_hash
    ActionCable.server.broadcast("conversations_#{message.conversation.id}_channel", serialized_data)
  rescue ActiveRecord::RecordNotFound
    return I18n.t("jobs.message_broadcast.error", message: message_id)
  end
end
