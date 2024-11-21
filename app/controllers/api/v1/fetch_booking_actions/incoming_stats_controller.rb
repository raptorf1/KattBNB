class Api::V1::FetchBookingActions::IncomingStatsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    head :no_content, status: 204 and return if current_api_v1_user.host_profile.nil?

    render json: Booking.get_booking_stats(current_api_v1_user.nickname, nil), status: 200
  end
end
