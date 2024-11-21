class Api::V1::FetchBookingActions::OutgoingStatsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    render json: Booking.get_booking_stats(nil, current_api_v1_user.id), status: 200
  end
end
