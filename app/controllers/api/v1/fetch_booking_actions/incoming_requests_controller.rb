class Api::V1::FetchBookingActions::IncomingRequestsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    head :no_content, status: 204 and return if current_api_v1_user.host_profile.nil?

    pending_bookings =
      Booking
        .where(status: "pending", host_nickname: current_api_v1_user.nickname)
        .sort_by { |booking| booking.created_at }
        .reverse
    render json: pending_bookings, each_serializer: Bookings::IndexSerializer, status: 200
  end
end
