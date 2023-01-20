class Api::V1::ReviewsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[show create update]

  def index
    render json: Review.get_sorted_reviews(params[:host_profile_id]), each_serializer: Reviews::Serializer, status: 200
  end

  def show
    review = Review.find(params[:id])
    if current_api_v1_user.id != review.user_id && current_api_v1_user.host_profile&.id != review.host_profile_id
      render json: { errors: [I18n.t("controllers.reusable.update_error")] }, status: 400 and return
    end

    render json: review, serializer: Reviews::Serializer
  end

  def create
    booking = Booking.find(params[:booking_id])
    if current_api_v1_user.id != booking.user_id || booking.dates.last > DateService.get_js_epoch
      render json: { errors: [I18n.t("controllers.reusable.update_error")] }, status: 400 and return
    end

    review = Review.create(review_params)
    render json: { errors: review.errors.full_messages }, status: 400 and return if !review.persisted?

    host = User.find_by(nickname: booking.host_nickname)
    user = User.find(booking.user_id)

    render json: { message: I18n.t("controllers.reusable.create_success") }, status: 200
    ReviewsMailer.delay(queue: "reviews_email_notifications").notify_host_create_review(host, booking, user, review)
  end

  def update
    review = Review.find(params[:id])

    if current_api_v1_user.nickname != review.host_nickname
      render json: { errors: [I18n.t("controllers.reusable.update_error")] }, status: 400 and return
    end

    if !review.host_reply.nil?
      render json: { errors: [I18n.t("controllers.reviews.update_error_reply_exists")] }, status: 400 and return
    end

    if params[:host_reply].length > 1000
      render json: { errors: [I18n.t("controllers.contactus.create_error_message")] }, status: 400 and return
    end

    review.update_attribute("host_reply", params[:host_reply])
    render json: { message: I18n.t("controllers.reusable.update_success") }, status: 200
  end

  private

  def review_params
    params.permit(:score, :body, :host_nickname, :user_id, :booking_id, :host_profile_id)
  end
end
