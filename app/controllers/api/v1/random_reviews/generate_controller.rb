class Api::V1::RandomReviews::GenerateController < ApplicationController
  def index
    high_score_reviews = Review.where(score: 5)
    reviews_to_send = []
    if high_score_reviews.length > 2
      high_score_reviews.each { |review| review.host_profile_id != nil && reviews_to_send.push(review) }
      render json: reviews_to_send.shuffle.first(3), each_serializer: Reviews::Serializer, status: 200
    else
      render json: { error: 'Not enough 5 paw reviews!' }, status: 404
    end
  end
end
