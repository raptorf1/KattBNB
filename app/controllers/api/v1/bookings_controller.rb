class Api::V1::BookingsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:index, :create, :update]

  def index
    params[:host_nickname] == current_api_v1_user.nickname ? bookings = Booking.where(host_nickname: params[:host_nickname]) : params[:user_id].to_i == current_api_v1_user.id ? bookings = Booking.where(user_id: params[:user_id]) : bookings = []
    render json: bookings, each_serializer: Bookings::IndexSerializer
  end

  def create
    booking = Booking.create(booking_params)
    if booking.persisted?
      host = User.where(nickname: booking.host_nickname)
      if host.length == 1
        profile = HostProfile.where(user_id: host[0].id)
        user = User.where(id: booking.user_id)
        if (booking.dates - profile[0].availability).empty? == true
          render json: { message: I18n.t('controllers.bookings.create_success') }, status: 200
          new_availability = profile[0].availability - booking.dates
          profile.update(availability: new_availability)
          booking.update(host_avatar: host[0].avatar)
          BookingsMailer.notify_host_create_booking(host[0], booking, user[0]).deliver
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

  def update
    booking = Booking.find(params[:id])
    if current_api_v1_user.nickname == booking.host_nickname
      user = User.where(id: booking.user_id)
      host = User.where(nickname: booking.host_nickname)
      profile = HostProfile.where(user_id: host[0].id)
      booking.update(status: params[:status], host_message: params[:host_message])
      if booking.persisted? == true && booking.host_message.length < 201 && booking.status == 'accepted'
        render json: { message: I18n.t('controllers.bookings.update_success') }, status: 200
        booking.update(host_description: profile[0].description, host_full_address: profile[0].full_address, host_real_lat: profile[0].latitude, host_real_long: profile[0].longitude)
        BookingsMailer.notify_user_accepted_booking(host[0], booking, user[0]).deliver
      elsif booking.persisted? == true && booking.host_message.length < 201 && booking.status == 'declined'
        new_availability = (profile[0].availability + booking.dates).sort
        profile.update(availability: new_availability)
        render json: { message: I18n.t('controllers.bookings.update_success') }, status: 200
        BookingsMailer.notify_user_declined_booking(host[0], booking, user[0]).deliver
      else
        render json: { error: booking.errors.full_messages }, status: 422
      end
    else
      render json: { error: I18n.t('controllers.bookings.update_error_1') }, status: 422
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: [I18n.t('controllers.bookings.update_error_2')] }, status: :not_found
  end

 
  private

  def booking_params
    params.permit(:number_of_cats, :message, :host_nickname, :price_per_day, :price_total, :user_id, :dates => [])
  end

end
