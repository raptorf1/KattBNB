class Api::V1::HostProfilesController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:show, :create, :update]


  def index
    params[:user_id] ? profiles = HostProfile.where(user_id: params[:user_id]) : params[:location] ? profiles = HostProfile.joins(:user).where(users: {location: params[:location]}) : profiles = HostProfile.all
    render json: profiles, each_serializer: HostProfiles::IndexSerializer
  end
  

  def show
    profile = HostProfile.find(params[:id])
    current_api_v1_user.id == profile.user_id ? (render json: profile, serializer: HostProfiles::ShowSerializer) : (render json: profile, serializer: HostProfiles::ShowSerializerNoAddress)
  end


  def create
    profile = HostProfile.create(host_profile_params)
    profile.persisted? ? (render json: { message: I18n.t('controllers.reusable.create_success') }, status: 200) : (render json: { error: profile.errors.full_messages }, status: 422)
  end


  def update
    profile = HostProfile.find(params[:id])

    if current_api_v1_user.id == profile.user_id && params[:availability]
      host = User.where(id: profile.user_id)
      bookings = Booking.where(host_nickname: host[0].nickname)
      if bookings.length > 0
        dates = []
        bookings.each do |booking|
          dates.push(booking.dates)
        end
        one_array_dates = dates.flatten
        comparison = params[:availability]&one_array_dates
        if comparison.length > 0
          render json: { error: 'Cannot update availability. You have incoming bookings to some of those dates!' }, status: 422
        else
          profile.update(host_profile_params)
          profile.persisted? == true && (render json: { message: I18n.t('controllers.host_profiles.update_success') }, status: 200)
        end
      else
        profile.update(host_profile_params)
        profile.persisted? == true && (render json: { message: I18n.t('controllers.host_profiles.update_success') }, status: 200)
      end
    elsif current_api_v1_user.id == profile.user_id
      profile.update(host_profile_params)
      profile.persisted? == true && (render json: { message: I18n.t('controllers.host_profiles.update_success') }, status: 200)
    else
      render json: { error: I18n.t('controllers.reusable.update_error') }, status: 422
    end
  end

  
  private

  def host_profile_params
    params.permit(:description, :full_address, :price_per_day_1_cat, :supplement_price_per_cat_per_day, :max_cats_accepted, :lat, :long, :latitude, :longitude, :user_id, :availability => [])
  end

end
