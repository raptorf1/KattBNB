RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::BookingsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }
  let(:user2) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner', location: 'Crete') }
  let(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:user3) { FactoryBot.create(:user, email: 'carla@craft.com', nickname: 'Carla', location: 'Stockholm') }
  let(:credentials3) { user3.create_new_auth_token }
  let(:headers3) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials3) }
  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/bookings' do

    before do
      booking = FactoryBot.create(:booking, user_id: user1.id, host_nickname: user2.nickname, dates: [1,2,3])
      booking2 = FactoryBot.create(:booking, user_id: user3.id, host_nickname: user2.nickname, dates: [4,5,6])
      review = FactoryBot.create(:review, user_id: user1.id, host_profile_id: profile2.id, booking_id: booking.id)
    end

    it 'returns 401 response if user not logged in' do
      get '/api/v1/bookings/', headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'returns an empty collection of bookings if no params are passed' do
      get '/api/v1/bookings', headers: headers1
      expect(json_response.count).to eq 0
      expect(Booking.all.length).to eq 2
    end

    it 'returns 200 response' do
      get '/api/v1/bookings', headers: headers1
      expect(response.status).to eq 200
    end

    it 'returns relevant stats for host if appropriate params are passed' do
      get "/api/v1/bookings?stats=yes&host_nickname=#{user2.nickname}&user_id=#{user2.id}", headers: headers2
      expect(json_response['stats'].to_json).to eq "{\"in_requests\":\"2\",\"in_upcoming\":\"0\",\"in_history\":\"0\",\"out_requests\":\"0\",\"out_upcoming\":\"0\",\"out_history\":\"0\"}"
    end

    it 'returns relevant stats for user if appropriate params are passed' do
      get "/api/v1/bookings?stats=yes&host_nickname=#{user1.nickname}&user_id=#{user1.id}", headers: headers1
      expect(json_response['stats'].to_json).to eq "{\"in_requests\":\"0\",\"in_upcoming\":\"0\",\"in_history\":\"0\",\"out_requests\":\"1\",\"out_upcoming\":\"0\",\"out_history\":\"0\"}"
    end

    it 'performance stats for stat returning' do
      get_request = get "/api/v1/bookings?stats=yes&host_nickname=#{user1.nickname}&user_id=#{user1.id}", headers: headers1
      expect { get_request }.to perform_under(1).ms.sample(20).times
      expect { get_request }.to perform_at_least(5000000).ips
    end
      
    it 'returns a booking by host nickname to the involved host' do
      get "/api/v1/bookings?stats=no&host_nickname=#{user2.nickname}", headers: headers2
      expect(json_response[0]['host_nickname']).to eq user2.nickname
      expect(json_response[1]['host_nickname']).to eq user2.nickname
      expect(json_response.count).to eq 2
    end

    it 'returns only dates sorted to 1 array of all booking dates to the involved host' do
      get "/api/v1/bookings?dates=only&stats=no&host_nickname=#{user2.nickname}", headers: headers2
      expect(json_response).to eq [1,2,3,4,5,6]
    end

    it 'returns a booking by host nickname in under 1 ms and with iteration rate of 5000000 per second' do
      get_request = get '/api/v1/bookings', params: {stats: 'no', host_nickname: user2.nickname}, headers: headers2
      expect { get_request }.to perform_under(1).ms.sample(20).times
      expect { get_request }.to perform_at_least(5000000).ips
    end

    it 'returns a booking by user id to the involved user' do
      get '/api/v1/bookings', params: {stats: 'no', user_id: user1.id}, headers: headers1
      expect(json_response[0]['user_id']).to eq user1.id
      expect(json_response.count).to eq 1
    end

    it 'returns a booking by user id in under 1 ms and with iteration rate of 5000000 per second' do
      get_request = get '/api/v1/bookings', params: {stats: 'no', user_id: user1.id}, headers: headers1
      expect { get_request }.to perform_under(1).ms.sample(20).times
      expect { get_request }.to perform_at_least(5000000).ips
    end

    it 'has correct keys in the response' do
      get '/api/v1/bookings', params: {stats: 'no', user_id: user1.id}, headers: headers1
      expect(json_response[0]).to include('id')
      expect(json_response[0]).to include('number_of_cats')
      expect(json_response[0]).to include('dates')
      expect(json_response[0]).to include('status')
      expect(json_response[0]).to include('message')
      expect(json_response[0]).to include('host_nickname')
      expect(json_response[0]).to include('price_total')
      expect(json_response[0]).to include('user_id')
      expect(json_response[0]).to include('host_id')
      expect(json_response[0]).to include('host_profile_id')
      expect(json_response[0]).to include('user')
      expect(json_response[0]).to include('created_at')
      expect(json_response[0]).to include('updated_at')
      expect(json_response[0]).to include('host_message')
      expect(json_response[0]).to include('host_description')
      expect(json_response[0]).to include('host_full_address')
      expect(json_response[0]).to include('host_location')
      expect(json_response[0]).to include('host_real_lat')
      expect(json_response[0]).to include('host_real_long')
      expect(json_response[0]).to include('host_avatar')
      expect(json_response[0]).to include('review_id')
      expect(json_response[0]).to include('host_profile_score')
      expect(json_response[0].count).to eq 22
    end

    it 'does not return a booking to an uninvolved user with host_nickname param' do
      get '/api/v1/bookings', params: {stats: 'no', host_nickname: user2.nickname}, headers: headers3
      expect(json_response.count).to eq 0
    end

    it 'does not return a booking to an uninvolved user with user_id param' do
      get '/api/v1/bookings', params: {stats: 'no', user_id: user1.id}, headers: headers3
      expect(json_response.count).to eq 0
    end
  end
end
