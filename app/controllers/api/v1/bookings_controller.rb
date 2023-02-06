class Api::V1::BookingsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: %i[create update]

  def create
    host = User.find_by(nickname: params[:host_nickname])
    if host.nil?
      StripeService.cancel_payment_intent(params[:payment_intent_id])
      render json: { errors: [I18n.t("controllers.bookings.create_error_2")] }, status: 400 and return
    end

    if !BookingService.validate_dates(params[:host_nickname], params[:dates].map(&:to_i))
      StripeService.cancel_payment_intent(params[:payment_intent_id])
      render json: { errors: [I18n.t("controllers.bookings.create_error_1")] }, status: 400 and return
    end

    booking_to_create = Booking.create(booking_params)
    if !booking_to_create.persisted?
      StripeService.cancel_payment_intent(params[:payment_intent_id])
      render json: { errors: booking_to_create.errors.full_messages }, status: 400 and return
    end

    user = User.find(booking_to_create.user_id)
    BookingsMailer.delay(queue: "bookings_email_notifications").notify_host_create_booking(
      host,
      booking_to_create,
      user
    )
    render json: { message: I18n.t("controllers.reusable.create_success") }, status: 200
  end

  def update
    Stripe.api_key = StripeService.get_api_key
    booking = Booking.find(params[:id])

    if current_api_v1_user.nickname != booking.host_nickname
      render json: { errors: [I18n.t("controllers.reusable.update_error")] }, status: 400 and return
    end

    booking.update(status: params[:status], host_message: params[:host_message])

    if booking.errors.full_messages.length > 0
      render json: { errors: booking.errors.full_messages }, status: 400 and return
    end

    user = User.find(booking.user_id)
    host = User.find_by(nickname: booking.host_nickname)
    profile = HostProfile.find_by(user_id: host.id)

    if booking.status == "declined"
      StripeService.cancel_payment_intent(booking.payment_intent_id)
      BookingsMailer.delay(queue: "bookings_email_notifications").notify_user_declined_booking(host, booking, user)
      render json: { message: I18n.t("controllers.bookings.update_success") }, status: 200 and return
    end

    begin
      !Rails.env.test? && Stripe::PaymentIntent.capture(booking.payment_intent_id)
    rescue Stripe::StripeError
      booking.update(status: "pending", host_message: nil)
      render json: { errors: [I18n.t("controllers.reusable.stripe_error")] }, status: 400
    else
      BookingService.cancel_same_date_pending_bookings_on_update(host, booking.dates, booking.id)
      booking.update(
        host_description: profile.description,
        host_full_address: profile.full_address,
        host_real_lat: profile.latitude,
        host_real_long: profile.longitude,
        host_profile_id: profile.id
      )
      new_availability = profile.availability - booking.dates
      profile.update(availability: new_availability)
      BookingsMailer.delay(queue: "bookings_email_notifications").notify_user_accepted_booking(host, booking, user)
      render json: { message: I18n.t("controllers.bookings.update_success") }, status: 200
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [I18n.t("controllers.bookings.update_error")] }, status: 400
  end

  private

  def booking_params
    params.permit(
      :number_of_cats,
      :message,
      :host_nickname,
      :price_per_day,
      :price_total,
      :payment_intent_id,
      :user_id,
      dates: []
    )
  end
end
