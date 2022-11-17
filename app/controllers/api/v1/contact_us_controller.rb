class Api::V1::ContactUsController < ApplicationController
  def index
    params[:message].length > 1000 &&
      (render json: { errors: [I18n.t("controllers.contactus.create_error_message")] }, status: 400) and return

    params[:name].length > 100 &&
      (render json: { errors: [I18n.t("controllers.contactus.create_error_name")] }, status: 400) and return

    !Truemail.valid?(params[:email]) &&
      (render json: { errors: [I18n.t("controllers.contactus.create_error_email")] }, status: 400) and return

    ContactusMailer.delay(queue: "contact_form_email_notifications").send_visitor_message(
      params[:name],
      params[:email],
      params[:message]
    )
    render json: { message: I18n.t("controllers.conversations.update_success") }, status: 200
  end
end
