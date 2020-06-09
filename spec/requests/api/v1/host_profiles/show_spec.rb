RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:user2) { FactoryBot.create(:user, email: 'felix@mail.com', nickname: 'MacOS') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }
    
    describe 'GET /api/v1/host_profiles/id' do
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
        get "/api/v1/host_profiles/#{HostProfile.last.id}", headers: headers
      end

      it 'returns a success response' do
        expect(response.status).to eq 200
      end

      it 'returns a specific host profile' do
        profile = HostProfile.last
        expect(json_response['id']).to eq profile.id
      end

      it 'has correct keys in the response' do
        expect(json_response).to include('id')
        expect(json_response).to include('description')
        expect(json_response).to include('price_per_day_1_cat')
        expect(json_response).to include('supplement_price_per_cat_per_day')
        expect(json_response).to include('max_cats_accepted')
        expect(json_response).to include('availability')
        expect(json_response).to include('forbidden_dates')
        expect(json_response).to include('full_address')
        expect(json_response).to include('score')
        expect(json_response).to include('review')
        expect(json_response).to include('user')
        expect(json_response.count).to eq 11
        end
      end

    describe 'GET /api/v1/host_profiles/id' do
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

      it 'fetches specific host profile in under 1 ms and with iteration rate of at least 5000000 per second' do
        get_request = get "/api/v1/host_profiles/#{HostProfile.last.id}", headers: headers
        expect { get_request }.to perform_under(1).ms.sample(20).times
        expect { get_request }.to perform_at_least(5000000).ips
      end
    end

    describe 'GET /api/v1/host_profiles/id' do
      it 'does not return full address unless the request comes from the user that created the host profile' do
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
        get "/api/v1/host_profiles/#{HostProfile.last.id}", headers: headers2
        expect(response.status).to eq 200
        expect(json_response.count).to eq 9
        expect(json_response).not_to include('full_address')
      end
    end

    describe 'GET /api/v1/host_profiles/id' do
      it 'requires user to be authenticated to see individual host profile' do
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
        get "/api/v1/host_profiles/#{HostProfile.last.id}", headers: not_headers
        expect(response.status).to eq 401
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
end
