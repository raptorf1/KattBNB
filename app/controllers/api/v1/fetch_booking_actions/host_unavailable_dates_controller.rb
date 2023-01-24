class Api::V1::FetchBookingActions::HostUnavailableDatesController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[index]

  def index
    render json: [], status: 200 and return if current_api_v1_user.host_profile.nil?

    render json: BookingService.get_host_unavailable_dates(current_api_v1_user.host_profile.id), status: 200
  end
end
