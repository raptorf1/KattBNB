class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:create]
  
  def create
    conversation = Conversation.find(params[:conversation_id])
    if params[:user_id].to_i == conversation.user1_id || params[:user_id].to_i == conversation.user2_id
      message = conversation.message.create(message_params)
      if message.persisted?
        render json: { message: 'Successfully created', body: message.body }
      else
        render json: { error: message.errors.full_messages }, status: 400
      end
    else
      render json: { error: 'You cannot perform this action' }, status: 422
    end 
  end
  
  private

  def message_params
    params.permit(:body, :user_id, :conversation_id)
  end

end
