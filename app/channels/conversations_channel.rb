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
    if conversation.hidden == nil
      @message = Message.create(conversation_id: data['conversation_id'], body: data['body'], user_id: data['user_id'])
      attach_image(data)
      if @message.errors.present?
        transmit({type: 'errors', data: @message.errors.full_messages})
      elsif conversation.user1_id == data['user_id'] || conversation.user2_id == data['user_id']
        user_sending = User.where(id: @message.user_id)
        if conversation.user1_id == @message.user_id
          user_receiving = User.where(id: conversation.user2_id)
        else
          user_receiving = User.where(id: conversation.user1_id)
        end
        MessageBroadcastJob.perform_later(@message.id)
        if user_receiving[0].message_notification == true
          MessagesMailer.notify_user_new_message(user_sending[0], user_receiving[0], @message.body).deliver
        end
      else
        @message.destroy
        transmit({type: 'errors', data: 'You cannot send message to a conversation you are not part of!'})
      end
    else
      conversation.update_attribute('hidden', nil)
      @message = Message.create(conversation_id: data['conversation_id'], body: data['body'], user_id: data['user_id'])
      attach_image(data)
      if @message.errors.present?
        transmit({type: 'errors', data: @message.errors.full_messages})
      elsif conversation.user1_id == data['user_id'] || conversation.user2_id == data['user_id']
        user_sending = User.where(id: @message.user_id)
        if conversation.user1_id == @message.user_id
          user_receiving = User.where(id: conversation.user2_id)
        else
          user_receiving = User.where(id: conversation.user1_id)
        end
        MessageBroadcastJob.perform_later(@message.id)
        if user_receiving[0].message_notification == true
          MessagesMailer.notify_user_new_message(user_sending[0], user_receiving[0], @message.body).deliver
        end
      else
        @message.destroy
        transmit({type: 'errors', data: 'You cannot send message to a conversation you are not part of!'})
      end
    end
  end


  private 

  def attach_image(data)
    if data['image'] && data['image'].present?
      DecodeImageService.attach_image(data['image'], @message.image)
    end
  end

end
