RSpec.describe 'GET /api/v1/host_profiles/id', type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:profile) { FactoryBot.create(:host_profile, user_id: user.id) }

  let(:user2) { FactoryBot.create(:user, email: 'felix@mail.com', nickname: 'MacOS') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'succesfully when request comes from associated user' do
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

  describe 'succesfully when request does not come from associated user' do
    before { get "/api/v1/host_profiles/#{profile.id}", headers: headers2 }

    it 'with correct number of keys in the response' do
      expect(json_response.count).to eq 8
    end

    it 'without full_address and stripe keys in the response' do
      expect(json_response).not_to include('full_address', 'stripe_state', 'stripe_account_id')
    end
  end

  describe 'unsuccesfully' do
    before { get "/api/v1/host_profiles/#{profile.id}", headers: not_headers }

    it 'with 401 status if user is not authenticated' do
      expect(response.status).to eq 401
    end

    it 'with relevant error if user is not authenticated' do
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
