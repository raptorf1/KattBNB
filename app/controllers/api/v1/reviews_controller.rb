class Api::V1::ReviewsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[show create update]

  def index
    render json: Review.get_sorted_reviews(params[:host_profile_id]), each_serializer: Reviews::Serializer, status: 200
  end

  def show
    review = Review.find(params[:id])
    if current_api_v1_user.id == review.user_id || current_api_v1_user.host_profile.id == review.host_profile_id
      render json: review, serializer: Reviews::Serializer
    else
      render json: { error: [I18n.t("controllers.reusable.update_error")] }, status: 422
    end
  rescue NoMethodError
    render json: { error: [I18n.t("controllers.reusable.update_error")] }, status: 422
  end

  def create
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    review = Review.create(review_params)
    if review.persisted?
      booking = Booking.find(params[:booking_id])
      if current_api_v1_user.id == booking.user_id && booking.status == "accepted" &&
           booking.dates.last < now_epoch_javascript
        host = User.where(nickname: booking.host_nickname)
        user = User.where(id: booking.user_id)
        render json: { message: I18n.t("controllers.reusable.create_success") }, status: 200
        ReviewsMailer.delay(queue: "reviews_email_notifications").notify_host_create_review(
          host[0],
          booking,
          user[0],
          review
        )
      else
        review.destroy
        render json: { error: [I18n.t("controllers.reusable.update_error")] }, status: 422
      end
    else
      render json: { error: review.errors.full_messages }, status: 422
    end
  end

  def update
    review = Review.find(params[:id])
    if current_api_v1_user.nickname == review.host_nickname && review.host_reply.nil?
      review.update_attribute("host_reply", params[:host_reply])
      render json: { message: I18n.t("controllers.reusable.update_success") }, status: 200
    else
      render json: { error: [I18n.t("controllers.reusable.update_error")] }, status: 422
    end
  end

  private

  def review_params
    params.permit(:score, :body, :host_nickname, :user_id, :booking_id, :host_profile_id)
  end
end
