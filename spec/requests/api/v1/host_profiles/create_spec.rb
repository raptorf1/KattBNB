RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'POST /api/v1/host_profile' do

    describe 'successfully' do
      before do
        post '/api/v1/host_profiles', params: {
          description: 'Hello, I am the best, better than the rest!',
          full_address: 'Solvarvsgatan 32, 41508, Göteborg, Sweden',
          price_per_day_1_cat: '100',
          supplement_price_per_cat_per_day: '35',
          max_cats_accepted: '3',
          availability: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
          lat: '57.746517',
          long: '12.028278',
          latitude: '57.746517',
          longitude: '12.028278',
          user_id: user.id
        }, 
        headers: headers
      end

      it 'creates a host profile' do
        expect(json_response['message']).to eq 'Successfully created'
        expect(response.status).to eq 200
      end
    end

    describe 'unsuccessfully' do
      it 'Host profile can not be created without all fields filled in' do
        post '/api/v1/host_profiles', params: {
          description: '',
          full_address: 'Solvarvsgatan 32, 41508, Göteborg, Sweden',
          price_per_day_1_cat: '100',
          supplement_price_per_cat_per_day: '35',
          max_cats_accepted: '3',
          availability: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
          lat: '57.746517',
          long: '12.028278',
          latitude: '57.746517',
          longitude: '12.028278',
          user_id: user.id
        }, 
        headers: headers

        expect(json_response['error']).to eq ["Description can't be blank"]
        expect(response.status).to eq 422
      end

      it 'Host profile can not be created if user is not logged in' do
        post '/api/v1/host_profiles', headers: not_headers
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
  end
end
