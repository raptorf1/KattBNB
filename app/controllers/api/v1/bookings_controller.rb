class Api::V1::BookingsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:index, :create, :update]

  def index
    if params[:host_nickname] == current_api_v1_user.nickname
      bookings = Booking.where(host_nickname: params[:host_nickname])
    elsif params[:user_id].to_i == current_api_v1_user.id
      bookings = Booking.where(user_id: params[:user_id])
    else
      bookings = []
    end
    render json: bookings, each_serializer: Bookings::IndexSerializer
  end

  def create
    booking = Booking.create(booking_params)
    
    if booking.persisted?
      host = User.where(nickname: booking.host_nickname)
      profile = HostProfile.where(user_id: host[0].id)
      user = User.where(id: booking.user_id)
      if (booking.dates - profile[0].availability).empty? == true
        render json: { message: 'Successfully created' }, status: 200
        new_availability = profile[0].availability - booking.dates
        profile.update(availability: new_availability)
        BookingsMailer.notify_host_create_booking(host[0], booking, user[0]).deliver        
      else
        booking.destroy
        render json: { error: ['Someone else just booked these days with this host!'] }, status: 422        
      end      
    else
      render json: { error: booking.errors.full_messages }, status: 422
    end
  end

  def update
    booking = Booking.find(params[:id])

    if current_api_v1_user.nickname == booking.host_nickname
      booking.update(status: params[:status], host_message: params[:host_message])
      if booking.persisted? == true && booking.host_message.length < 201 && booking.status == 'accepted'
        render json: { message: 'You have successfully updated this booking' }, status: 200
      elsif booking.persisted? == true && booking.host_message.length < 201 && booking.status == 'declined'
        host = User.where(nickname: booking.host_nickname)
        profile = HostProfile.where(user_id: host[0].id)
        new_availability = (profile[0].availability + booking.dates).sort
        profile.update(availability: new_availability)
        render json: { message: 'You have successfully updated this booking' }, status: 200
      else
        render json: { error: booking.errors.full_messages }, status: 422
      end
    else
      render json: { error: 'You cannot perform this action' }, status: 422
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: ['We cannot update this booking because the user requested an account deletion! Please go back to your bookings page'] }, status: :not_found
  end

 
  private

  def booking_params
    params.permit(:number_of_cats, :message, :host_nickname, :price_per_day, :price_total, :user_id, :dates => [])
  end

end
