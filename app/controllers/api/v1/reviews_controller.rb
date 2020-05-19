class Api::V1::ReviewsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:create]

  def create
    booking = Booking.create(booking_params)
    if booking.persisted?
      host = User.where(nickname: booking.host_nickname)
      if host.length == 1
        profile = HostProfile.where(user_id: host[0].id)
        user = User.where(id: booking.user_id)
        if (booking.dates - profile[0].availability).empty? == true
          render json: { message: I18n.t('controllers.reusable.create_success') }, status: 200
          new_availability = profile[0].availability - booking.dates
          profile.update(availability: new_availability)
          booking.update(host_avatar: host[0].avatar)
          BookingsMailer.delay(:queue => 'bookings_email_notifications').notify_host_create_booking(host[0], booking, user[0])
        else
          booking.update(status: 'canceled')
          booking.destroy
          render json: { error: [I18n.t('controllers.bookings.create_error_1')] }, status: 422
        end
      else
        booking.destroy
        render json: { error: [I18n.t('controllers.bookings.create_error_2')] }, status: 422
      end
    else
      render json: { error: booking.errors.full_messages }, status: 422
    end
  end

 
  private

  def review_params
    params.permit(:score, :body, :host_nickname)
  end

end
