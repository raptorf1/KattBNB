RSpec.describe 'GET /api/v1/stripe_actions/update_payment_intent', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

  Stripe.api_key = StripeService.get_api_key

  describe 'successfully' do
    describe 'if valid payment intent is provided and dates are less than 500 characters' do
      before do
        intent =
          Stripe::PaymentIntent.create(
            { amount: 3000, currency: 'sek', receipt_email: 'test@test.com', capture_method: 'manual' }
          )
        get "/api/v1/stripe_actions/update_payment_intent?payment_intent_id=#{intent.client_secret}&dates=1587945600000,1588204800000&number_of_cats=2&message=I love you&host_nickname=Alonso&price_per_day=100&price_total=856.36&user_id=12",
            headers: headers
      end

      it 'with relevant message' do
        expect(json_response['message']).to eq 'Payment Intent updated!'
      end

      it 'with 200 status' do
        expect(response.status).to eq 200
      end
    end

    describe 'if valid payment intent is provided and dates are over 500 characters' do
      before do
        intent =
          Stripe::PaymentIntent.create(
            { amount: 3000, currency: 'sek', receipt_email: 'test@test.com', capture_method: 'manual' }
          )
        get "/api/v1/stripe_actions/update_payment_intent?payment_intent_id=#{intent.client_secret}&dates=1587945600000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000,1588204800000&number_of_cats=2&message=I love you&host_nickname=Alonso&price_per_day=100&price_total=856.36&user_id=12",
            headers: headers
      end

      it 'with relevant message' do
        expect(json_response['message']).to eq 'Payment Intent updated!'
      end

      it 'with 200 status' do
        expect(response.status).to eq 200
      end
    end
  end

  describe 'unsuccesfully' do
    describe 'if stripe servers report an error on updating a payment intent' do
      before do
        get '/api/v1/stripe_actions/update_payment_intent?payment_intent_id=pi_3KnhFqC7PrB6N0LYqNluH_secret_0zan8hHNvtnlaqleu6SGRXBoi&dates=1587945600000,1588204800000',
            headers: headers
      end

      it 'with relevant error' do
        expect(
          json_response['error']
        ).to eq 'There was a problem connecting to our payments infrastructure provider. Please try again later.'
      end

      it 'with 555 status' do
        expect(response.status).to eq 555
      end
    end

    describe 'if user is not authenticated and tries to update a stripe payment intent' do
      before { get '/api/v1/stripe_actions/update_payment_intent', headers: unauthenticated_headers }

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'with 401 status' do
        expect(response.status).to eq 401
      end
    end
  end
end
