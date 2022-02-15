RSpec.describe 'GET /api/v1/host_profiles/id', type: :request do
  let(:profile) { FactoryBot.create(:host_profile) }
  let(:credentials) { profile.user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(random_credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    describe 'when request comes from associated user' do
      before { get "/api/v1/host_profiles/#{profile.id}", headers: headers }

      it 'with 200 status' do
        expect(response.status).to eq 200
      end

      it 'returns the specific host profile' do
        expect(json_response['id']).to eq profile.id
      end

      it 'with correct number of keys in the response' do
        expect(json_response.count).to eq 11
      end

      it 'with correct keys in the response' do
        expect(json_response).to include(
          'id',
          'description',
          'price_per_day_1_cat',
          'supplement_price_per_cat_per_day',
          'max_cats_accepted',
          'availability',
          'full_address',
          'score',
          'stripe_state',
          'stripe_account_id',
          'user'
        )
      end
    end

    describe 'when request does not come from associated user' do
      before { get "/api/v1/host_profiles/#{profile.id}", headers: random_user_headers }

      it 'with correct number of keys in the response' do
        expect(json_response.count).to eq 8
      end

      it 'without full_address and stripe keys in the response' do
        expect(json_response).not_to include('full_address', 'stripe_state', 'stripe_account_id')
      end
    end
  end

  describe 'unsuccesfully if not authenticated' do
    before { get "/api/v1/host_profiles/#{profile.id}", headers: unauthenticated_headers }

    it 'with 401 status' do
      expect(response.status).to eq 401
    end

    it 'with relevant error' do
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
