class Api::V1::FetchBookingActions::OutgoingUpcomingController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    accepted_bookings = Booking.where(status: "accepted", user_id: current_api_v1_user.id)
    upcoming_bookings =
      accepted_bookings
        .select { |booking| booking.dates.last >= DateService.get_js_epoch }
        .sort_by { |booking| booking.dates.first }

    render json: upcoming_bookings, each_serializer: Bookings::IndexSerializer, status: 200
  end
end
