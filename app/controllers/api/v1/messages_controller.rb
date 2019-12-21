class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:create]
  
  def create
    conversation = Conversation.find(params[:conversation_id])

    message = conversation.messages.create(message_params)
    if message.persisted?
      render json: { message: 'Successfully created', body: message.body }
    else
      render json: { error: review.errors.full_messages }, status: 400
    end
   
  end
  
  private

  def message_params
    params.permit(:body, :user_id, :conversation_id)
  end

end
