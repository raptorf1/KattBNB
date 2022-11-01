class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[update]

  def show
    user = User.find(params[:id])
    render json: user, serializer: Users::Serializer
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User with ID #{params[:id]} not found" }, status: 404
  end

  def update
    user = User.find(params[:id])
    if current_api_v1_user.id == user.id && params[:client] != nil && params['access-token'] != nil &&
         params[:profile_avatar] != nil
      client = params[:client]
      token = params['access-token']
      pic = params[:profile_avatar]
      if user.valid_token?(token, client)
        attach_image(pic, user)
        user.update(avatar: pic[0])
        render json: { message: I18n.t('controllers.reusable.update_success') }, status: 200
      else
        render json: { error: [I18n.t('controllers.reusable.update_error')] }, status: 422
      end
    else
      render json: { error: [I18n.t('controllers.reusable.update_error')] }, status: 422
    end
  end

  private

  def attach_image(avatar, user)
    (avatar && avatar.present?) && DecodeImageService.attach_image(avatar, user.profile_avatar)
  end
end
