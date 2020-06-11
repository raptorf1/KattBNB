class Api::V1::ReviewsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:show, :create, :update]

  def index
    params[:host_profile_id] ? reviews = Review.where(host_profile_id: params[:host_profile_id]) : reviews = []
    render json: reviews, each_serializer: Reviews::Serializer
  end

  def show
    review = Review.find(params[:id])
    current_api_v1_user.id == review.user_id || current_api_v1_user.nickname == review.host_nickname ? (render json: review, serializer: Reviews::Serializer) : (render json: { error: [I18n.t('controllers.reusable.update_error')] }, status: 422)
  end

  def create
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    review = Review.create(review_params)
    if review.persisted?
      booking = Booking.find(params[:booking_id])
      if current_api_v1_user.id == booking.user_id && booking.dates.last < now_epoch_javascript
        render json: { message: I18n.t('controllers.reusable.create_success') }, status: 200
      else
        review.destroy
        render json: { error: [I18n.t('controllers.reusable.update_error')] }, status: 422
      end
    else      
      render json: { error: review.errors.full_messages }, status: 422
    end
  end

  def update
    review = Review.find(params[:id])
    if current_api_v1_user.nickname == review.host_nickname && review.host_reply == nil && review.user_id != nil && review.booking_id != nil
      review.update(host_reply: params[:host_reply])
      render json: { message: I18n.t('controllers.reusable.update_success') }, status: 200
    else
      render json: { error: [I18n.t('controllers.reusable.update_error')] }, status: 422
    end
  end

 
  private

  def review_params
    params.permit(:score, :body, :host_nickname, :user_id, :booking_id, :host_profile_id)
  end

end
