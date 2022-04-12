RSpec.describe 'GET /api/v1/stripe_actions/create_payment_intent', type: :request do
  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'unsuccesfully' do
    describe 'if user is not authenticated and tries to create a stripe payment intent' do
      before { get '/api/v1/stripe_actions/create_payment_intent', headers: unauthenticated_headers }

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'with 401 status' do
        expect(response.status).to eq 401
      end
    end
  end
end
