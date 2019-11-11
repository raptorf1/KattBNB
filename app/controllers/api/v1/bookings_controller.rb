class Api::V1::BookingsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:create]

  def create
    booking = Booking.create(booking_params)
    
    if booking.persisted?
      render json: { message: 'Successfully created' }, status: 200
    else
      render json: { error: booking.errors.full_messages }, status: 422
    end    
  end

 
  private

  def booking_params
    params.permit(:number_of_cats, :message, :host_nickname, :price_per_day, :price_total, :user_id, :dates => [])
  end

end
