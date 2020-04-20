RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let(:another_user) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner', location: 'Crete') }
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/host_profiles' do

    before do
      profile_user = FactoryBot.create(:host_profile, user_id: user.id)
      profile_another_user = FactoryBot.create(:host_profile, user_id: another_user.id)
    end

    it 'returns a collection of host profiles' do
      get '/api/v1/host_profiles', headers: headers
      expect(json_response.count).to eq 2
      expect(HostProfile.all.length).to eq 2
    end

    it 'returns 200 response' do
      get '/api/v1/host_profiles', headers: headers
      expect(response.status).to eq 200
    end

    it 'fetches collection of host profiles in under 1 ms and with iteration rate of at least 5000000 per second' do
      get_request = get '/api/v1/host_profiles', headers: headers
      expect { get_request }.to perform_under(1).ms.sample(20).times
      expect { get_request }.to perform_at_least(5000000).ips
    end

    describe 'for a specific user' do
      
      it "responds with specific user's host profile" do
        get '/api/v1/host_profiles', params: {user_id: another_user.id}
        expect(json_response[0]['user']['id']).to eq another_user.id
        expect(json_response.count).to eq 1
      end
    end

    describe 'for a specific location' do
      
      it "responds with specific host profiles according to user's location" do
        get '/api/v1/host_profiles', params: {location: another_user.location}
        expect(json_response[0]['user']['location']).to eq another_user.location
        expect(json_response.count).to eq 1
      end
    end
  end

end
