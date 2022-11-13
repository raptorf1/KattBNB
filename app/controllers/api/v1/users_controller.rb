class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[update]

  def show
    user = User.find_by(id: params[:id])

    user.nil? && (render json: { error: "User with ID #{params[:id]} not found!", time: Time.current }, status: 400) and
      return

    render json: user, serializer: Users::Serializer, status: 200
  end

  def update
    user = User.find_by(id: params[:id])

    user.nil? && (render json: { error: "User with ID #{params[:id]} not found!", time: Time.current }, status: 400) and
      return

    current_api_v1_user.id != user.id &&
      (render json: { error: [I18n.t("controllers.reusable.update_error")], time: Time.current }, status: 400) and
      return

    params[:profile_avatar].nil? && (render json: { error: "No avatar supplied!", time: Time.current }, status: 400) and
      return

    pic = params[:profile_avatar]
    DecodeImageService.attach_image(pic, user.profile_avatar)
    user.update(avatar: pic[0])
    render json: { message: I18n.t("controllers.reusable.update_success") }, status: 200
  end
end
