class Api::V1::ContactusController < ApplicationController
  def index
    if Truemail.valid?(params[:email])
      render json: { message: 'Success!!!' }, status: 200
      # new mailer here
    else
      render json: { error: [I18n.t('controllers.contactus.create_error')] }, status: 422
    end
  end
end
