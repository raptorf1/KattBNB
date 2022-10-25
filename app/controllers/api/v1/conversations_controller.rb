class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[create index show update]

  def index
    # pehaps send off something other then 200 on unassociated request
    if params[:user_id].to_i == current_api_v1_user.id
      conversations = Conversation.where(user1_id: params[:user_id]).or(Conversation.where(user2_id: params[:user_id]))
    else
      conversations = []
    end
    render json: conversations, each_serializer: Conversations::IndexSerializer
  end

  def show
    conversation = Conversation.find(params[:id])
    if conversation.user1_id == current_api_v1_user.id || conversation.user2_id == current_api_v1_user.id
      (
        render json: conversation,
               include: [message: [:user]],
               serializer: Conversations::ShowSerializer,
               scope: current_api_v1_user
      )
    else
      (render json: { error: I18n.t("controllers.reusable.update_error") }, status: 422)
    end
  end

  def create
    conversation_exists =
      Conversation.where(user1_id: params[:user1_id], user2_id: params[:user2_id]).or(
        Conversation.where(user1_id: params[:user2_id], user2_id: params[:user1_id])
      )
    if conversation_exists.length == 1
      render json: {
               message: I18n.t("controllers.conversations.create_exists"),
               id: conversation_exists[0].id
             },
             status: 200
    else
      conversation = Conversation.create(conversation_params)
      if conversation.persisted?
        render json: { message: I18n.t("controllers.reusable.create_success"), id: conversation.id }, status: 200
      else
        render json: { error: conversation.errors.full_messages }, status: 422
      end
    end
  end

  def update
    conversation = Conversation.find(params[:id])
    if conversation.user1_id == current_api_v1_user.id || conversation.user2_id == current_api_v1_user.id
      if conversation.hidden == nil
        conversation.update_attribute("hidden", params[:hidden])
        conversation.persisted? == true &&
          (render json: { message: I18n.t("controllers.conversations.update_success") }, status: 200)
      else
        conversation.destroy
      end
    else
      render json: { error: I18n.t("controllers.reusable.update_error") }, status: 422
    end
  end

  private

  def conversation_params
    params.permit(:user1_id, :user2_id)
  end
end
