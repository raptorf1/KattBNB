RSpec.describe 'POST /api/v1/host_profile', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

  def post_request(desc)
    post '/api/v1/host_profiles',
         params: {
           description: desc,
           full_address: 'Solvarvsgatan 32, 41508, Göteborg, Sweden',
           price_per_day_1_cat: '100',
           supplement_price_per_cat_per_day: '35',
           max_cats_accepted: '3',
           availability: [
             1_562_803_200_000,
             1_562_889_600_000,
             1_562_976_000_000,
             1_563_062_400_000,
             1_563_148_800_000
           ],
           lat: '57.746517',
           long: '12.028278',
           latitude: '57.746517',
           longitude: '12.028278',
           user_id: user.id
         },
         headers: headers
  end

  describe 'successfully' do
    before { post_request('Hello, I am the best, better than the rest!') }

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with relevant message' do
      expect(json_response['message']).to eq 'Successfully created!'
    end

    it 'with assigning a value to stripe_state field' do
      expect(HostProfile.last.stripe_state.include?(user.nickname)).to eq true
    end
  end

  describe 'unsuccessfully' do
    describe 'when all fields are not filled in' do
      before { post_request('') }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq ["Description can't be blank"]
      end
    end

    describe 'when user is not logged in' do
      before { post '/api/v1/host_profiles', headers: unauthenticated_headers }

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
  end
end
