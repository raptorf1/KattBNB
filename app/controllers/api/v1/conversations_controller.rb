class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index show create update]

  def index
    render json: Conversation.get_and_sort_conversations(current_api_v1_user.id),
           each_serializer: Conversations::IndexSerializer,
           status: 200
  end

  def show
    conversation = Conversation.find(params[:id])

    if conversation.user1_id != current_api_v1_user.id && conversation.user2_id != current_api_v1_user.id
      (render json: { errors: [I18n.t("controllers.reusable.update_error")] }, status: 400) and return
    end

    render json: conversation,
           include: [message: [:user]],
           serializer: Conversations::ShowSerializer,
           scope: current_api_v1_user,
           status: 200
  end

  def create
    conversation_exists = Conversation.check_conversation_exists_before_creating(params[:user1_id], params[:user2_id])
    if !conversation_exists.nil?
      (
        render json: {
                 message: I18n.t("controllers.conversations.create_exists"),
                 id: conversation_exists
               },
               status: 200
      ) and return
    end

    conversation_to_create = Conversation.create(conversation_params)
    if !conversation_to_create.persisted?
      (render json: { errors: conversation_to_create.errors.full_messages }, status: 400) and return
    end

    render json: { message: I18n.t("controllers.reusable.create_success"), id: conversation_to_create.id }, status: 200
  end

  def update
    conversation = Conversation.find(params[:id])

    if conversation.user1_id != current_api_v1_user.id && conversation.user2_id != current_api_v1_user.id
      (render json: { errors: [I18n.t("controllers.reusable.update_error")] }, status: 400) and return
    end

    if !conversation.hidden.nil?
      conversation.destroy
      return
    end

    conversation.update_attribute("hidden", current_api_v1_user.id)
    (render json: { errors: conversation.errors.full_messages }, status: 400) and return if !conversation.persisted?

    render json: { message: I18n.t("controllers.conversations.update_success") }, status: 200
  end

  private

  def conversation_params
    params.permit(:user1_id, :user2_id)
  end
end
