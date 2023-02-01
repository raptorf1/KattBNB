class Api::V1::FetchBookingActions::OutgoingHistoryController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    bookings_declined_canceled = Booking.where(status: %w[declined canceled], user_id: current_api_v1_user.id)
    accepted_bookings = Booking.where(status: "accepted", user_id: current_api_v1_user.id)
    history_bookings_accepted = accepted_bookings.select { |booking| booking.dates.last < DateService.get_js_epoch }
    all_history_bookings = bookings_declined_canceled + history_bookings_accepted
    render json: all_history_bookings, each_serializer: Bookings::IndexSerializer, status: 200
  end
end
