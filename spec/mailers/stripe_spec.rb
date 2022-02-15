RSpec.describe StripeMailer, type: :mailer do
  let(:new_stripe_mail) { StripeMailer.notify_orphan_payment_intent_to_cancel('pi_testing123with123rspec') }
  let(:new_stripe_mail2) { StripeMailer.notify_stripe_webhook_error('Signature Error') }
  let(:new_stripe_mail3) { StripeMailer.notify_stripe_webhook_dispute_fraud }

  describe 'notify_orphan_payment_intent_to_cancel' do
    it 'renders the subject' do
      expect(new_stripe_mail.subject).to eql('Cancel authorization of Stripe Payment Intent')
    end

    it 'renders the receiver email' do
      expect(new_stripe_mail.to).to eql(['george@kattbnb.se'])
    end

    it 'renders the sender email' do
      expect(new_stripe_mail.from).to eql('KattBNB meow-reply')
    end

    it 'contains the payment intent to cancel' do
      expect(new_stripe_mail.body.encoded).to match('pi_testing123with123rspec')
    end
  end

  describe 'notify_stripe_webhook_error' do
    it 'renders the subject' do
      expect(new_stripe_mail2.subject).to eql('Signature Error')
    end

    it 'renders the receiver email' do
      expect(new_stripe_mail2.to).to eql(['george@kattbnb.se'])
    end

    it 'renders the sender email' do
      expect(new_stripe_mail2.from).to eql('KattBNB meow-reply')
    end
  end

  describe 'notify_stripe_webhook_dispute_fraud' do
    it 'renders the subject' do
      expect(new_stripe_mail3.subject).to eql('New dispute or fraud detected')
    end

    it 'renders the receiver email' do
      expect(new_stripe_mail2.to).to eql(['george@kattbnb.se'])
    end

    it 'renders the sender email' do
      expect(new_stripe_mail2.from).to eql('KattBNB meow-reply')
    end
  end
end
