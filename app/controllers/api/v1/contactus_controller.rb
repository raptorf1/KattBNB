class Api::V1::ContactusController < ApplicationController
  def index
    if Truemail.valid?(params[:email])
      ContactusMailer.delay(queue: 'contact_form_email_notifications').send_visitor_message(params[:name], params[:email], params[:message])
      render json: { message: 'Success!!!' }, status: 200
    else
      render json: { error: [I18n.t('controllers.contactus.create_error')] }, status: 422
    end
  end
end
