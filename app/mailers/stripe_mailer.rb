class StripeMailer < ApplicationMailer

  def notify_orphan_payment_intent_to_cancel(payment_intent_id)
    @payment_intent = payment_intent_id

    mail(to: 'george@kattbnb.se', subject: 'Cancel authorization of Stripe Payment Intent')
  end

end
