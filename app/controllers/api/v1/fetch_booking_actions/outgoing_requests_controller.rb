class Api::V1::FetchBookingActions::OutgoingRequestsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    pending_bookings =
      Booking.where(status: "pending", user_id: current_api_v1_user.id).sort_by { |booking| booking.created_at }.reverse
    render json: pending_bookings, each_serializer: Bookings::IndexSerializer, status: 200
  end
end
