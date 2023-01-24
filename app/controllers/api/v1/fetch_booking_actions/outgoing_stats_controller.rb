class Api::V1::FetchBookingActions::OutgoingStatsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    pending_bookings = Booking.where(status: "pending", user_id: current_api_v1_user.id).size
    history_bookings_declined_canceled =
      Booking.where(status: %w[declined canceled], user_id: current_api_v1_user.id).size
    accepted_bookings = Booking.where(status: "accepted", user_id: current_api_v1_user.id).select("dates")

    upcoming_bookings = accepted_bookings.select { |booking| booking.dates.last >= DateService.get_js_epoch }.size
    history_bookings_accepted = accepted_bookings.size - upcoming_bookings

    render json: {
             stats: {
               out_requests: pending_bookings,
               out_upcoming: upcoming_bookings,
               out_history: history_bookings_accepted + history_bookings_declined_canceled
             }
           },
           status: 200
  end
end
