class Api::V1::ContactUsController < ApplicationController
  def index
    params[:message].length > 1000 &&
      (render json: { error: [I18n.t("controllers.contactus.create_error_message")] }, status: 422) and return

    params[:name].length > 100 &&
      (render json: { error: [I18n.t("controllers.contactus.create_error_name")] }, status: 422) and return

    !Truemail.valid?(params[:email]) &&
      (render json: { error: [I18n.t("controllers.contactus.create_error_email")] }, status: 422) and return

    ContactusMailer.delay(queue: "contact_form_email_notifications").send_visitor_message(
      params[:name],
      params[:email],
      params[:message]
    )
    render json: { message: "Success!!!" }, status: 200
  end
end
