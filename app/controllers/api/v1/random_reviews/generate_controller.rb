class Api::V1::RandomReviews::GenerateController < ApplicationController

  def index
    render json: { message: 'yay!!!' }, status: 200
    #params[:host_profile_id] ? reviews = Review.where(host_profile_id: params[:host_profile_id]) : reviews = []
    #render json: reviews, each_serializer: Reviews::Serializer
  end
end
