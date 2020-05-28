class Api::V1::UsersController < ApplicationController

  def update
    user = User.find(params[:id])
    if params[:client] != nil && params['access-token'] != nil && params[:profile_avatar] != nil
      client = params[:client]
      token = params['access-token']
      pic = params[:profile_avatar]
      if user.valid_token?(token, client)
        attach_image(pic, user)
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
