class Api::V1::RandomReviews::ReviewsController < ApplicationController
  def index
    high_score_reviews = Review.get_high_score_reviews

    high_score_reviews.length < 3 &&
      (render json: { error: [I18n.t("controllers.random_reviews.error")] }, status: 400) and return

    render json: high_score_reviews.shuffle.first(3), each_serializer: Reviews::Serializer, status: 200
  end
end
