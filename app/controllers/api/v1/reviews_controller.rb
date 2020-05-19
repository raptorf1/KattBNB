class Api::V1::ReviewsController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:create]

  def create
    review = Review.create(review_params)
    if review.persisted?
      booking = Booking.find(params[:booking_id])
      if current_api_v1_user.id == booking.user_id
        render json: { message: I18n.t('controllers.reusable.create_success') }, status: 200
      else
        review.destroy
        render json: { error: [I18n.t('controllers.reusable.update_error')] }, status: 422
      end
    else      
      render json: { error: review.errors.full_messages }, status: 422
    end
  end

 
  private

  def review_params
    params.permit(:score, :body, :host_nickname, :user_id, :booking_id, :host_profile_id)
  end

end
