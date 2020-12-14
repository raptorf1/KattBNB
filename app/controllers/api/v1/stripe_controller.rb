class Api::V1::StripeController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    profile = HostProfile.where(id: params[:host_profile_id])
    Stripe.api_key = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_API_KEY_PROD : Rails.application.credentials.STRIPE_API_KEY_DEV
    if params[:occasion] == 'retrieve' && current_api_v1_user.id == profile[0].user_id
      stripe_account = profile[0].stripe_account_id
      if stripe_account
        begin
          response = Stripe::Account.retrieve(stripe_account)
          render json: { payouts_enabled: response.payouts_enabled, requirements: response.requirements }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
        end
      else
        render json: { message: 'No account' }, status: 200
      end
    elsif params[:occasion] == 'login_link' && current_api_v1_user.id == profile[0].user_id
      stripe_account = profile[0].stripe_account_id
      if stripe_account
        begin
          response = Stripe::Account.create_login_link(stripe_account)
          render json: { url: response.url }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
        end
      end
    elsif params[:occasion] == 'create_payment_intent'
      if calculate_price(params[:inDate], params[:outDate], params[:cats], params[:host]) == params[:amount]
        stripe_amount = params[:amount]
        if stripe_amount.include? '.'
          stripe_amount = stripe_amount.delete '.'
        else
          stripe_amount = params[:amount] + '00'
        end
        begin
          intent = Stripe::PaymentIntent.create({
            amount: stripe_amount,
            currency: params[:currency],
            receipt_email: current_api_v1_user.email,
            capture_method: 'manual'
          })
          render json: { intent_id: intent.client_secret }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
        end
      else
        render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
      end
    elsif params[:occasion] == 'update_payment_intent'
      payment_intent_id = params[:payment_intent_id].split('_secret')[0]
      begin
        Stripe::PaymentIntent.update(payment_intent_id,
          { metadata:
            {
              number_of_cats: params[:number_of_cats],
              message: params[:message],
              dates: params[:dates],
              host_nickname: params[:host_nickname],
              price_per_day: params[:price_per_day],
              price_total: params[:price_total],
              user_id: params[:user_id],
              payment_intent_id: payment_intent_id
            }
         },
        )
        render json: { message: 'Payment Intent updated!' }, status: 200
      rescue Stripe::StripeError
        render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
      end
    elsif params[:occasion] == 'delete_account' && current_api_v1_user.id == profile[0].user_id
      stripe_account = profile[0].stripe_account_id
      if stripe_account
        begin
          Stripe::Account.delete(stripe_account)
          render json: { message: 'Account deleted!' }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
        end
      else
        render json: { message: 'No account' }, status: 200
      end
    else
      render json: { error: I18n.t('controllers.reusable.update_error') }, status: 422
    end
  end

  def create
    render json: { message: 'Success!' }, status: 200
    Stripe.api_key = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_API_KEY_PROD : Rails.application.credentials.STRIPE_API_KEY_DEV
    endpoint_secret = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_WEBHOOK_SIGN_PROD : Rails.application.credentials.STRIPE_WEBHOOK_SIGN_TEST
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil
    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      if event.type == 'charge.succeeded'
        payment_intent = params['data']['object']['payment_intent']
        number_of_cats = params['data']['object']['metadata']['number_of_cats']
        message = params['data']['object']['metadata']['message']
        dates_string = params['data']['object']['metadata']['dates']
        dates = dates_string.split(',').map(&:to_i)
        host_nickname = params['data']['object']['metadata']['host_nickname']
        price_per_day = params['data']['object']['metadata']['price_per_day']
        price_total = params['data']['object']['metadata']['price_total']
        user_id = params['data']['object']['metadata']['user_id']
        Delayed::Job.enqueue CreateBookingForDummies.new(payment_intent, number_of_cats, message, dates, host_nickname, price_per_day, price_total, user_id)
      elsif event.type == 'charge.dispute.created' || event.type == 'issuing_dispute.created' || event.type == 'radar.early_fraud_warning.created'
        StripeMailer.delay(:queue => 'stripe_email_notifications').notify_stripe_webhook_dispute_fraud
      else
        puts "Unhandled event type: #{event.type}. Why are we receiving this again???"
      end
    rescue JSON::ParserError
      StripeMailer.delay(:queue => 'stripe_email_notifications').notify_stripe_webhook_error('Webhook JSON Parse Error')
    rescue Stripe::SignatureVerificationError
      StripeMailer.delay(:queue => 'stripe_email_notifications').notify_stripe_webhook_error('Webhook Signature Verification Error')
    rescue Stripe::StripeError
      StripeMailer.delay(:queue => 'stripe_email_notifications').notify_stripe_webhook_error('General Stripe Webhook Error')
    end
  end


  class CreateBookingForDummies < Struct.new(:payment_intent, :number_of_cats, :message, :dates, :host_nickname, :price_per_day, :price_total, :user_id)
    def perform
      Stripe.api_key = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_API_KEY_PROD : Rails.application.credentials.STRIPE_API_KEY_DEV
      sleep(10)
      booking_exists = Booking.where(payment_intent_id: payment_intent)
        if booking_exists.length == 0
          booking_to_create = Booking.create(payment_intent_id: payment_intent, number_of_cats: number_of_cats, message: message, dates: dates, host_nickname: host_nickname, price_per_day: price_per_day, price_total: price_total, user_id: user_id)
          if booking_to_create.persisted?
            host = User.where(nickname: booking_to_create.host_nickname)
            if host.length == 1
              profile = HostProfile.where(user_id: host[0].id)
              user = User.where(id: booking_to_create.user_id)
              if (booking_to_create.dates - profile[0].availability).empty? == true
                new_availability = profile[0].availability - booking_to_create.dates
                profile.update(availability: new_availability)
                BookingsMailer.delay(:queue => 'bookings_email_notifications').notify_host_create_booking(host[0], booking_to_create, user[0])
              else
                begin
                  Stripe::PaymentIntent.cancel(booking_to_create.payment_intent_id)
                rescue Stripe::StripeError
                  StripeMailer.delay(:queue => 'stripe_email_notifications').notify_orphan_payment_intent_to_cancel(booking_to_create.payment_intent_id)
                end
                booking_to_create.update(status: 'canceled')
                booking_to_create.destroy
              end
            else
              begin
                Stripe::PaymentIntent.cancel(booking_to_create.payment_intent_id)
              rescue Stripe::StripeError
                StripeMailer.delay(:queue => 'stripe_email_notifications').notify_orphan_payment_intent_to_cancel(booking_to_create.payment_intent_id)
              end
              booking_to_create.destroy
            end
          else
            begin
              Stripe::PaymentIntent.cancel(booking_to_create.payment_intent_id)
            rescue Stripe::StripeError
              StripeMailer.delay(:queue => 'stripe_email_notifications').notify_orphan_payment_intent_to_cancel(booking_to_create.payment_intent_id)
            end
          end
        else
          puts 'Booking already exists! Show me the moneyyyyy!'
        end
    end
  end


  private

  def calculate_price (in_date, out_date, cats, host)
    user = User.find_by(nickname: host)
    if user != nil
      host_profile = HostProfile.find_by(user_id: user.id)
      if host_profile != nil
        price = host_profile.price_per_day_1_cat + ((cats.to_i - 1) * host_profile.supplement_price_per_cat_per_day)
        total = price * (((out_date.to_i - in_date.to_i) / 86400000) + 1)
        final_charge = total + (total * 0.17) + ((total * 0.17) * 0.25)
        '%.2f' % final_charge
      else
        '%.2f' % 0
      end
    else
      '%.2f' % 0
    end
  end

end
