class Api::V1::FetchBookingActions::IncomingStatsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    head :no_content, status: 204 and return if current_api_v1_user.host_profile.nil?

    pending_bookings = Booking.where(status: "pending", host_nickname: current_api_v1_user.nickname).size
    unpaid_bookings = Booking.where(status: "accepted", host_nickname: current_api_v1_user.nickname, paid: false).size
    history_bookings_declined_canceled =
      Booking.where(status: %w[declined canceled], host_nickname: current_api_v1_user.nickname).size
    accepted_bookings = Booking.where(status: "accepted", host_nickname: current_api_v1_user.nickname).select("dates")

    upcoming_bookings = accepted_bookings.select { |booking| booking.dates.last >= DateService.get_js_epoch }.size
    history_bookings_accepted = accepted_bookings.size - upcoming_bookings

    render json: {
             stats: {
               in_requests: pending_bookings,
               in_upcoming: upcoming_bookings,
               in_history: history_bookings_accepted + history_bookings_declined_canceled,
               in_unpaid: unpaid_bookings
             }
           },
           status: 200
  end
end
