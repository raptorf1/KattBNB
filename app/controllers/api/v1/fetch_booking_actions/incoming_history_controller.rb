class Api::V1::FetchBookingActions::IncomingHistoryController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    render json: [], status: 200 and return if current_api_v1_user.host_profile.nil?

    bookings_declined_canceled =
      Booking.where(status: %w[declined canceled], host_nickname: current_api_v1_user.nickname)
    accepted_bookings = Booking.where(status: "accepted", host_nickname: current_api_v1_user.nickname)
    history_bookings_accepted = accepted_bookings.select { |booking| booking.dates.last < DateService.get_js_epoch }
    all_history_bookings = bookings_declined_canceled + history_bookings_accepted
    render json: all_history_bookings, each_serializer: Bookings::IndexSerializer, status: 200
  end
end
