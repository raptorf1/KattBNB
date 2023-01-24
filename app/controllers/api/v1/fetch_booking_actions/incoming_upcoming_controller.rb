class Api::V1::FetchBookingActions::IncomingUpcomingController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    render json: [], status: 200 and return if current_api_v1_user.host_profile.nil?

    accepted_bookings = Booking.where(status: "accepted", host_nickname: current_api_v1_user.nickname)
    upcoming_bookings = accepted_bookings.select { |booking| booking.dates.last >= DateService.get_js_epoch }

    render json: upcoming_bookings, each_serializer: Bookings::IndexSerializer, status: 200
  end
end
