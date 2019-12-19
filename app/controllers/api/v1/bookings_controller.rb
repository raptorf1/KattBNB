class Api::V1::BookingsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:index, :create, :update, :destroy]

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
      if host.length == 1
        profile = HostProfile.where(user_id: host[0].id)
        user = User.where(id: booking.user_id)
        if (booking.dates - profile[0].availability).empty? == true
          render json: { message: 'Successfully created' }, status: 200
          new_availability = profile[0].availability - booking.dates
          profile.update(availability: new_availability)
          booking.update(host_avatar: host[0].avatar)
          BookingsMailer.notify_host_create_booking(host[0], booking, user[0]).deliver
        else
          booking.destroy
          render json: { error: ['Someone else just requested to book these days with this host!'] }, status: 422
        end
      else
        booking.destroy
        render json: { error: ['Booking cannot be created because the host requested an account deletion! Please find another host in the results page.'] }, status: 422
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
        render json: { message: 'You have successfully updated this booking' }, status: 200
        booking.update(host_description: profile[0].description, host_full_address: profile[0].full_address, host_real_lat: profile[0].latitude, host_real_long: profile[0].longitude)
        BookingsMailer.notify_user_accepted_booking(host[0], booking, user[0]).deliver
      elsif booking.persisted? == true && booking.host_message.length < 201 && booking.status == 'declined'
        new_availability = (profile[0].availability + booking.dates).sort
        profile.update(availability: new_availability)
        render json: { message: 'You have successfully updated this booking' }, status: 200
        BookingsMailer.notify_user_declined_booking(host[0], booking, user[0]).deliver
      else
        render json: { error: booking.errors.full_messages }, status: 422
      end
    else
      render json: { error: 'You cannot perform this action' }, status: 422
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: ['We cannot update this booking because the user requested an account deletion! Please go back to your bookings page.'] }, status: :not_found
  end

  def destroy
    booking = Booking.find(params[:id])
    host = User.where(nickname: booking.host_nickname)
    now = (Time.now.to_f * 1000).to_i
    
    if current_api_v1_user.id == booking.user_id && booking.present? == true && booking.destroyed? == false
      if booking.status == 'declined' || booking.status == 'canceled'
        booking.destroy
        render json: { message: 'You have successfully deleted this declined or canceled booking' }, status: 200
      elsif booking.status == 'pending'
        profile = HostProfile.where(user_id: host[0].id)
        new_availability = (profile[0].availability + booking.dates).sort
        profile.update(availability: new_availability)
        booking.destroy
        render json: { message: 'You have successfully deleted this pending booking' }, status: 200
      elsif booking.status == 'accepted' && booking.dates[booking.dates.length - 1] > now
        # send email to host
        booking.destroy
      end
    else
      render json: { error: 'You cannot perform this action' }, status: 422
    end  
  end

 
  private

  def booking_params
    params.permit(:number_of_cats, :message, :host_nickname, :price_per_day, :price_total, :user_id, :dates => [])
  end

end
