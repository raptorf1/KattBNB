class Api::V1::BookingsController < ApplicationController
  include BookingsConcern

  before_action :authenticate_api_v1_user!, only: %i[index create update]

  def index
    case
    when params[:stats] == "yes" && params[:host_nickname] == current_api_v1_user.nickname &&
           params[:user_id].to_i == current_api_v1_user.id
      now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
      now_epoch_javascript = (now.to_f * 1000).to_i
      incoming_bookings = Booking.where(host_nickname: params[:host_nickname])
      incoming_requests = []
      incoming_upcoming = []
      incoming_history = []
      incoming_unpaid = []
      incoming_bookings.each do |booking|
        case
        when booking.status == "pending"
          incoming_requests.push(booking)
        when booking.status == "accepted" && booking.dates.last > now_epoch_javascript
          incoming_upcoming.push(booking)
        else
          incoming_history.push(booking)
        end
        incoming_unpaid.push(booking) if booking.status == "accepted" && booking.paid == false
      end
      outgoing_bookings = Booking.where(user_id: params[:user_id])
      outgoing_requests = []
      outgoing_upcoming = []
      outgoing_history = []
      outgoing_unpaid = []
      outgoing_bookings.each do |booking|
        case
        when booking.status == "pending"
          outgoing_requests.push(booking)
        when booking.status == "accepted" && booking.dates.last > now_epoch_javascript
          outgoing_upcoming.push(booking)
        else
          outgoing_history.push(booking)
        end
        outgoing_unpaid.push(booking) if booking.status == "accepted" && booking.paid == false
      end
      render json: {
               stats: {
                 in_requests: "#{incoming_requests.length}",
                 in_upcoming: "#{incoming_upcoming.length}",
                 in_history: "#{incoming_history.length}",
                 in_unpaid: "#{incoming_unpaid.length}",
                 out_requests: "#{outgoing_requests.length}",
                 out_upcoming: "#{outgoing_upcoming.length}",
                 out_history: "#{outgoing_history.length}",
                 out_unpaid: "#{outgoing_unpaid.length}"
               }
             },
             status: 200
    when params[:stats] == "no" && params[:host_nickname] == current_api_v1_user.nickname
      if params.has_key?("dates")
        bookings = []
        host = User.where(nickname: params[:host_nickname])
        profile = HostProfile.where(user_id: host[0].id)
        if profile.length == 1
          render json: find_host_bookings(profile[0].id, 0)
        else
          render json: bookings
        end
      else
        bookings = Booking.where(host_nickname: params[:host_nickname])
        render json: bookings, each_serializer: Bookings::IndexSerializer
      end
    when params[:stats] == "no" && params[:user_id].to_i == current_api_v1_user.id
      bookings = Booking.where(user_id: params[:user_id])
      render json: bookings, each_serializer: Bookings::IndexSerializer
    else
      bookings = []
      render json: bookings, each_serializer: Bookings::IndexSerializer
    end
  end

  def create
    booking = Booking.create(booking_params)
    if booking.persisted?
      host = User.where(nickname: booking.host_nickname)
      if host.length == 1
        profile = HostProfile.where(user_id: host[0].id)
        user = User.where(id: booking.user_id)
        if (booking.dates - find_host_bookings(profile[0].id, booking.id)) == booking.dates
          render json: { message: I18n.t("controllers.reusable.create_success") }, status: 200
          BookingsMailer.delay(queue: "bookings_email_notifications").notify_host_create_booking(
            host[0],
            booking,
            user[0]
          )
        else
          cancel_payment_intent(booking.payment_intent_id)
          booking.destroy
          render json: { error: [I18n.t("controllers.bookings.create_error_1")] }, status: 422
        end
      else
        cancel_payment_intent(booking.payment_intent_id)
        booking.destroy
        render json: { error: [I18n.t("controllers.bookings.create_error_2")] }, status: 422
      end
    else
      cancel_payment_intent(booking.payment_intent_id)
      render json: { error: booking.errors.full_messages }, status: 422
    end
  end

  def update
    Stripe.api_key =
      if ENV["OFFICIAL"] == "yes"
        Rails.application.credentials.STRIPE_API_KEY_PROD
      else
        Rails.application.credentials.STRIPE_API_KEY_DEV
      end
    booking = Booking.find(params[:id])
    if current_api_v1_user.nickname == booking.host_nickname
      user = User.where(id: booking.user_id)
      host = User.where(nickname: booking.host_nickname)
      profile = HostProfile.where(user_id: host[0].id)
      booking.update(status: params[:status], host_message: params[:host_message])
      case
      when booking.persisted? == true && booking.host_message.length < 201 && booking.status == "accepted"
        if (booking.dates - find_host_bookings(profile[0].id, booking.id)) == booking.dates
          begin
            !Rails.env.test? && Stripe::PaymentIntent.capture(booking.payment_intent_id)
            render json: { message: I18n.t("controllers.bookings.update_success") }, status: 200
            booking.update(
              host_description: profile[0].description,
              host_full_address: profile[0].full_address,
              host_real_lat: profile[0].latitude,
              host_real_long: profile[0].longitude,
              host_profile_id: profile[0].id
            )
            new_availability = profile[0].availability - booking.dates
            profile.update(availability: new_availability)
            BookingsMailer.delay(queue: "bookings_email_notifications").notify_user_accepted_booking(
              host[0],
              booking,
              user[0]
            )
          rescue Stripe::StripeError
            booking.update(status: "pending", host_message: nil)
            render json: { error: I18n.t("controllers.reusable.stripe_error") }, status: 555
          end
        else
          render json: { error: I18n.t("controllers.bookings.update_error_same_dates") }, status: 427
          booking.update(
            status: "canceled",
            host_message:
              "This booking got canceled by KattBNB. The host has accepted another booking in that date range."
          )
          BookingsMailer.delay(queue: "bookings_email_notifications").notify_user_declined_booking(
            host[0],
            booking,
            user[0]
          )
          cancel_payment_intent(booking.payment_intent_id)
        end
      when booking.persisted? == true && booking.host_message.length < 201 && booking.status == "declined"
        render json: { message: I18n.t("controllers.bookings.update_success") }, status: 200
        BookingsMailer.delay(queue: "bookings_email_notifications").notify_user_declined_booking(
          host[0],
          booking,
          user[0]
        )
        cancel_payment_intent(booking.payment_intent_id)
      else
        render json: { error: booking.errors.full_messages }, status: 422
      end
    else
      render json: { error: I18n.t("controllers.reusable.update_error") }, status: 422
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: [I18n.t("controllers.bookings.update_error")] }, status: :not_found
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
