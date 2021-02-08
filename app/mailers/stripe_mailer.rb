class StripeMailer < ApplicationMailer
  def notify_orphan_payment_intent_to_cancel(payment_intent_id)
    @payment_intent = payment_intent_id

    mail(to: 'george@kattbnb.se', subject: 'Cancel authorization of Stripe Payment Intent')
  end

  def notify_stripe_webhook_error(subject_text)
    mail(to: 'george@kattbnb.se', subject: subject_text)
  end

  def notify_stripe_webhook_dispute_fraud
    mail(to: 'george@kattbnb.se', subject: 'New dispute or fraud detected')
  end
end
