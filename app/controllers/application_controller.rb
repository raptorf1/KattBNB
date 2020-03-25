class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?



  protected

  def configure_permitted_parameters 
    devise_parameter_sanitizer.permit(:sign_up, keys: [:location, :nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:location, :avatar, :message_notification])
  end


  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

end




