RSpec.describe Api::V1::BookingsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }
  let(:user2) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner', location: 'Crete') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:user3) { FactoryBot.create(:user, email: 'carla@craft.com', nickname: 'Carla', location: 'Stockholm') }
  let(:credentials3) { user3.create_new_auth_token }
  let(:headers3) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials3) }
  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/bookings' do

    before do
      booking = FactoryBot.create(:booking, user_id: user1.id, host_nickname: user2.nickname)
    end

    it 'returns 401 response if user not logged in' do
      get '/api/v1/bookings/', headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'returns an empty collection of bookings if no params are passed' do
      get '/api/v1/bookings', headers: headers1
      expect(json_response.count).to eq 0
      expect(Booking.all.length).to eq 1
    end

    it 'returns 200 response' do
      get '/api/v1/bookings', headers: headers1
      expect(response.status).to eq 200
    end
      
    it 'returns a booking by host nickname to the involved host' do
      get '/api/v1/bookings', params: {host_nickname: user2.nickname}, headers: headers2
      expect(json_response[0]['host_nickname']).to eq user2.nickname
      expect(json_response.count).to eq 1
    end

    it 'returns a booking by user id to the involved user' do
      get '/api/v1/bookings', params: {user_id: user1.id}, headers: headers1
      expect(json_response[0]['user_id']).to eq user1.id
      expect(json_response.count).to eq 1
    end

    it 'does not return a booking to an uninvolved user with host_nickname param' do
      get '/api/v1/bookings', params: {host_nickname: user2.nickname}, headers: headers3
      expect(json_response.count).to eq 0
    end

    it 'does not return a booking to an uninvolved user with user_id param' do
      get '/api/v1/bookings', params: {user_id: user1.id}, headers: headers3
      expect(json_response.count).to eq 0
    end
  end
end
