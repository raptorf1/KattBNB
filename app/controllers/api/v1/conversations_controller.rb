class Api::V1::ConversationsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:create]


  def create
    conversation_exists = Conversation.where(user1_id: params[:user1_id], user2_id: params[:user2_id]).or(Conversation.where(user1_id: params[:user2_id], user2_id: params[:user1_id]))

    if conversation_exists.length == 1
      render json: { message: 'Conversation already exists', id: conversation_exists[0].id}, status: 200
    else
      conversation = Conversation.create(conversation_params)
      if conversation.persisted?
        render json: { message: 'Successfully created', id: conversation.id }, status: 200
      end
    end
  end

 
  private

  def conversation_params
    params.permit(:user1_id, :user2_id)
  end

end
