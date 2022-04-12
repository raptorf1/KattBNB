RSpec.describe 'GET /api/v1/stripe_actions/update_payment_intent', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

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
