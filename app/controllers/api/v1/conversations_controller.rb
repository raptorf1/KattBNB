class Api::V1::ConversationsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:create, :index]


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

  def index
    if params[:user_id].to_i == current_api_v1_user.id
      conversations = Conversation.where(user1_id: params[:user_id]).or(Conversation.where(user2_id: params[:user_id]))
    else
      conversations = []
    end
    render json: conversations
  end

  def show
    conversation = Conversation.find(params[:id])
    if conversation.user1_id == current_api_v1_user.id || conversation.user2_id == current_api_v1_user.id
      render json: conversation, include: [message: [:user]], serializer: Conversations::ShowSerializer
    else
      render json: { error: 'You cannot perform this action' }, status: 422
    end
  end
 
  private

  def conversation_params
    params.permit(:user1_id, :user2_id)
  end

end
