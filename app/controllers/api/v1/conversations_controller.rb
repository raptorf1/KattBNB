class Api::V1::ConversationsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:create]


  def create
    conversation = Conversation.create(conversation_params)

    if conversation.persisted?
      render json: { message: 'Successfully created', id: conversation.id }, status: 200
    end

  end

 
  private

  def conversation_params
    params.permit(:user1_id, :user2_id)
  end

end
