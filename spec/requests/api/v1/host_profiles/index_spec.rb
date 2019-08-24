RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:another_user) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner') }
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/host_profiles' do

    before do
      profile_user = FactoryBot.create(:host_profile, user_id: user.id)
      profile_another_user = FactoryBot.create(:host_profile, user_id: another_user.id)
    end

    it 'returns a collection of host profiles' do
      get '/api/v1/host_profiles', headers: headers
      expect(json_response['data'].count).to eq 2
    end

    it 'returns 200 response' do
      get '/api/v1/host_profiles', headers: headers
      expect(response.status).to eq 200
    end
    
    it 'has correct keys in the response' do
      get '/api/v1/host_profiles', headers: headers

      profiles = HostProfile.all

      profiles.each do |profile|
        expect(json_response['data'][profiles.index(profile)]).to include('id')
        expect(json_response['data'][profiles.index(profile)]).to include('price_per_day_1_cat')
        expect(json_response['data'][profiles.index(profile)]).to include('supplement_price_per_cat_per_day')
        expect(json_response['data'][profiles.index(profile)]).to include('max_cats_accepted')
        expect(json_response['data'][profiles.index(profile)]).to include('availability')
        expect(json_response['data'][profiles.index(profile)]).to include('lat')
        expect(json_response['data'][profiles.index(profile)]).to include('long')
      end
    end

    describe 'for a specific user' do
      
      it "responds with specific user's host profile" do
        get '/api/v1/host_profiles', params: {user_id: another_user.id}
        user_profile = HostProfile.where(user_id: another_user.id)
        expect(json_response['data'][0]['user_id']).to eq another_user.id
        expect(json_response.count).to eq 1
      end
    end
  end
end
