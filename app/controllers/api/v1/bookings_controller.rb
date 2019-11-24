class Api::V1::BookingsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:index, :create]

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
    @booking = Booking.create(booking_params)
    
    if @booking.persisted?
      render json: { message: 'Successfully created' }, status: 200
      binding.pry
      @host = User.where(nickname: @booking.host_nickname)
      BookingsMailer.notify_host(@host[0], @booking).deliver
    else
      render json: { error: @booking.errors.full_messages }, status: 422
    end    
  end

 
  private

  def booking_params
    params.permit(:number_of_cats, :message, :host_nickname, :price_per_day, :price_total, :user_id, :dates => [])
  end

end
