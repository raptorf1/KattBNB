class Api::V1::FetchBookingActions::IncomingRequestsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    head :no_content, status: 204 and return if current_api_v1_user.host_profile.nil?

    render json: Booking.get_request_bookings_sorted(current_api_v1_user.nickname, nil),
           each_serializer: Bookings::IndexSerializer,
           status: 200
  end
end
