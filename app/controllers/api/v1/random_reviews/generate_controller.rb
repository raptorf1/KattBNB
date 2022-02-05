class Api::V1::RandomReviews::GenerateController < ApplicationController

  def index
    high_score_reviews = Review.where(score: 5)
    if high_score_reviews.length > 2
      render json: high_score_reviews.shuffle.first(3), each_serializer: Reviews::Serializer, status: 200
    else
      render json: { error: 'Not enough 5 paw reviews!' }, status: 404
    end
  end

end
