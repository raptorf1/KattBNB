RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let!(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id, max_cats_accepted: 5, availability: [1587945600000, 1588032000000, 1588118400000, 1588204800000]) }
  let(:another_user) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner', location: 'Crete') }
  let!(:profile_another_user) { FactoryBot.create(:host_profile, user_id: another_user.id, max_cats_accepted: 7, availability: [1588032000000, 1588118400000, 1588204800000]) }
  let(:a_third_user) { FactoryBot.create(:user, email: 'carla@craft.com', nickname: 'The hair', location: 'Rhodos') }
  let!(:profile_third_user) { FactoryBot.create(:host_profile, user_id: a_third_user.id, max_cats_accepted: 3, availability: []) }
  let(:booking) { FactoryBot.create(:booking, user_id: user.id) }
  let!(:review) { FactoryBot.create(:review, user_id: user.id, booking_id: booking.id, host_profile_id: profile_user.id) }
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/host_profiles' do

    it 'returns a collection of host profiles' do
      get '/api/v1/host_profiles?cats=2&startDate=1588032000000&endDate=1588204800000', headers: headers
      expect(json_response['with'].count).to eq 2
      expect(json_response['without'].count).to eq 1
      expect(HostProfile.all.length).to eq 3
    end

    it 'returns 200 response' do
      get '/api/v1/host_profiles?cats=2&startDate=1588032000000&endDate=1588204800000', headers: headers
      expect(response.status).to eq 200
    end

    it 'performs sorting according to date params and returns host profiles accordingly' do
      get '/api/v1/host_profiles?cats=2&startDate=1587945600000&endDate=1588118400000', headers: headers
      expect(json_response['with'].count).to eq 1
      expect(json_response['with'][0]['id']).to eq profile_user.id
      expect(json_response['without'].count).to eq 2
    end

    it 'performs sorting according to cat params and returns host profiles accordingly' do
      get '/api/v1/host_profiles?cats=6&startDate=1588032000000&endDate=1588118400000', headers: headers
      expect(json_response['with'].count).to eq 1
      expect(json_response['with'][0]['id']).to eq profile_another_user.id
      expect(json_response['without'].count).to eq 0
    end

    it 'performs sorting according to cat and date params and returns host profiles accordingly' do
      get '/api/v1/host_profiles?cats=8&startDate=1588118400000&endDate=1588291200000', headers: headers
      expect(json_response['with'].count).to eq 0
      expect(json_response['without'].count).to eq 0
    end

    it 'returns the correct number of reviews if there are any' do
      get '/api/v1/host_profiles?cats=2&startDate=1588032000000&endDate=1588204800000', headers: headers
      with_review = json_response['with'].select { |profile| profile['reviews_count'] == 1 }
      no_review = json_response['with'].select { |profile| profile['reviews_count'] == nil }
      expect(with_review.length).to eq 1
      expect(no_review.length).to eq 1
      expect(with_review[0]['id']).to eq profile_user.id
      expect(no_review[0]['id']).to eq profile_another_user.id
    end

    it 'fetches collection of host profiles in under 1 ms and with iteration rate of at least 5000000 per second' do
      get_request = get '/api/v1/host_profiles?cats=2&startDate=1588032000000&endDate=1588204800000', headers: headers
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
        get '/api/v1/host_profiles', params: {location: another_user.location, cats: 2, startDate: 1588032000000, endDate: 1588204800000}
        expect(json_response['with'][0]['user']['location']).to eq another_user.location
        expect(json_response['with'].count).to eq 1
        expect(json_response['without'].count).to eq 0
      end

      it "responds with specific host profiles according to user's location and sorted based on date params" do
        get '/api/v1/host_profiles', params: {location: another_user.location, cats: 2, startDate: 1588032000000, endDate: 1588291200000}
        expect(json_response['with'].count).to eq 0
        expect(json_response['without'].count).to eq 1
      end

      it "responds with specific host profiles according to user's location and sorted based on cat params" do
        get '/api/v1/host_profiles', params: {location: another_user.location, cats: 10, startDate: 1588032000000, endDate: 1588204800000}
        expect(json_response['with'].count).to eq 0
        expect(json_response['without'].count).to eq 0
      end

    end
  end
end
