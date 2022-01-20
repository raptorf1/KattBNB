RSpec.describe 'GET /api/v1/bookings', type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }
  let!(:booking1) do
    FactoryBot.create(
      :booking,
      user_id: user1.id,
      host_nickname: user2.nickname,
      status: 'accepted',
      dates: [1, 2, 3, 2_562_889_600_000]
    )
  end

  let(:user2) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner', location: 'Crete') }
  let(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }

  let(:user3) { FactoryBot.create(:user, email: 'carla@craft.com', nickname: 'Carla', location: 'Stockholm') }
  let(:credentials3) { user3.create_new_auth_token }
  let(:headers3) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials3) }
  let!(:booking3) do
    FactoryBot.create(
      :booking,
      user_id: user3.id,
      host_nickname: user2.nickname,
      status: 'accepted',
      dates: [4, 5, 6, 2_462_889_600_000]
    )
  end

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    describe 'according to params' do
      describe 'when no params are passed' do
        before { get '/api/v1/bookings', headers: headers1 }

        it 'with empty collection of bookings' do
          expect(json_response.count).to eq 0
        end

        it 'with 200 status' do
          expect(response.status).to eq 200
        end
      end

      describe 'when appropriate params are passed' do
        it 'with relevant stats for host' do
          get "/api/v1/bookings?stats=yes&host_nickname=#{user2.nickname}&user_id=#{user2.id}", headers: headers2
          expect(
            json_response['stats'].to_json
          ).to eq "{\"in_requests\":\"0\",\"in_upcoming\":\"2\",\"in_history\":\"0\",\"in_unpaid\":\"2\",\"out_requests\":\"0\",\"out_upcoming\":\"0\",\"out_history\":\"0\",\"out_unpaid\":\"0\"}"
        end

        it 'with relevant stats for user' do
          get "/api/v1/bookings?stats=yes&host_nickname=#{user1.nickname}&user_id=#{user1.id}", headers: headers1
          expect(
            json_response['stats'].to_json
          ).to eq "{\"in_requests\":\"0\",\"in_upcoming\":\"0\",\"in_history\":\"0\",\"in_unpaid\":\"0\",\"out_requests\":\"0\",\"out_upcoming\":\"1\",\"out_history\":\"0\",\"out_unpaid\":\"1\"}"
        end
      end
    end

    describe 'according to user/host' do
      describe 'for host' do
        it 'with only dates sorted to one array' do
          get "/api/v1/bookings?dates=only&stats=no&host_nickname=#{user2.nickname}", headers: headers2
          expect(json_response).to eq [1, 2, 3, 4, 5, 6, 2_462_889_600_000, 2_562_889_600_000]
        end

        it 'with correct number of bookings' do
          get "/api/v1/bookings?stats=no&host_nickname=#{user2.nickname}", headers: headers2
          expect(json_response.count).to eq 2
        end
      end

      describe 'for user' do
        describe 'when involved' do
          before { get '/api/v1/bookings', params: { stats: 'no', user_id: user1.id }, headers: headers1 }

          it 'with correct number of bookings' do
            expect(json_response.count).to eq 1
          end

          it 'with correct booking' do
            expect(json_response.first['id']).to eq booking1.id
          end

          it 'with correct number of keys in the response' do
            expect(json_response.first.count).to eq 22
          end

          it 'with correct keys in the response' do
            expect(json_response.first).to include(
              'id',
              'number_of_cats',
              'dates',
              'status',
              'message',
              'host_nickname',
              'price_total',
              'user_id',
              'host_id',
              'host_profile_id',
              'user',
              'host_message',
              'host_description',
              'host_full_address',
              'host_location',
              'host_real_lat',
              'host_real_long',
              'host_avatar',
              'review_id',
              'host_profile_score'
            )
          end
        end

        describe 'when not involved' do
          it 'with correct number of bookings with host_nickname param' do
            get '/api/v1/bookings', params: { stats: 'no', host_nickname: user2.nickname }, headers: headers3
            expect(json_response.count).to eq 0
          end

          it 'with correct number of bookings with user_id param' do
            get '/api/v1/bookings', params: { stats: 'no', user_id: user1.id }, headers: headers3
            expect(json_response.count).to eq 0
          end
        end
      end
    end
  end

  describe 'unsuccessfully if user not logged in' do
    before { get '/api/v1/bookings/', headers: not_headers }

    it 'with 401 status' do
      expect(response.status).to eq 401
    end

    it 'with relevant error' do
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
