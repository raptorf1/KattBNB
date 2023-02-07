class Api::V1::HostProfilesController < ApplicationController
  include BookingsConcern

  before_action :authenticate_api_v1_user!, only: %i[show create update]

  def index
    #look at this in the future (namespace each param - different route - find a way to shorten the renders)
    if params[:user_id]
      profiles = HostProfile.where(user_id: params[:user_id])
      render json: profiles, each_serializer: HostProfiles::IndexSerializer
    elsif params[:location]
      profiles = HostProfile.location_cached(params[:location])
      render json: {
               with:
                 ActiveModel::Serializer::CollectionSerializer.new(
                   profiles_to_send(profiles, params[:cats], params[:startDate], params[:endDate])["with"],
                   serializer: HostProfiles::IndexSerializer
                 ),
               without:
                 ActiveModel::Serializer::CollectionSerializer.new(
                   profiles_to_send(profiles, params[:cats], params[:startDate], params[:endDate])["without"],
                   serializer: HostProfiles::IndexSerializer
                 )
             }
    else
      profiles = HostProfile.all_cached
      render json: {
               with:
                 ActiveModel::Serializer::CollectionSerializer.new(
                   profiles_to_send(profiles, params[:cats], params[:startDate], params[:endDate])["with"],
                   serializer: HostProfiles::IndexSerializer
                 ),
               without:
                 ActiveModel::Serializer::CollectionSerializer.new(
                   profiles_to_send(profiles, params[:cats], params[:startDate], params[:endDate])["without"],
                   serializer: HostProfiles::IndexSerializer
                 )
             }
    end
  end

  def show
    profile = HostProfile.find(params[:id])

    current_api_v1_user.id != profile.user_id &&
      (render json: profile, serializer: HostProfiles::ShowSerializerNoAddress, status: 200) and return

    render json: profile, serializer: HostProfiles::ShowSerializer, status: 200
  end

  def create
    profile = HostProfile.create(host_profile_params)

    !profile.persisted? && (render json: { errors: profile.errors.full_messages }, status: 400) and return

    render json: { message: I18n.t("controllers.reusable.create_success") }, status: 200
  end

  def update
    profile = HostProfile.find(params[:id])

    current_api_v1_user.id != profile.user_id &&
      (render json: { errors: [I18n.t("controllers.reusable.update_error")] }, status: 400) and return

    profile.update(host_profile_params)

    profile.errors.full_messages.length > 0 && (render json: { errors: profile.errors.full_messages }, status: 400) and
      return

    render json: { message: I18n.t("controllers.host_profiles.update_success") }, status: 200
  end

  private

  def host_profile_params
    params.permit(
      :description,
      :full_address,
      :price_per_day_1_cat,
      :supplement_price_per_cat_per_day,
      :max_cats_accepted,
      :lat,
      :long,
      :latitude,
      :longitude,
      :user_id,
      availability: []
    )
  end

  def profiles_to_send(profiles, cats, startDate, endDate)
    profiles_to_send = { "with" => [], "without" => [] }
    booking_dates = []
    start_date = startDate.to_i
    stop_date = endDate.to_i
    current_date = start_date
    while (current_date <= stop_date)
      booking_dates.push(current_date)
      current_date = current_date + 86_400_000
    end
    profiles.each do |profile|
      if profile.max_cats_accepted >= cats.to_i
        if booking_dates - profile.availability == []
          profiles_to_send["with"].push(profile)
        elsif booking_dates - find_host_bookings(profile.id, 0) == booking_dates
          profiles_to_send["without"].push(profile)
        end
      end
    end
    profiles_to_send
  end
end
