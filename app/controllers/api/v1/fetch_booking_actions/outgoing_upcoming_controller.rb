class Api::V1::FetchBookingActions::OutgoingUpcomingController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    render json: Booking.get_upcoming_bookings_sorted(nil, current_api_v1_user.id),
           each_serializer: Bookings::IndexSerializer,
           status: 200
  end
end
