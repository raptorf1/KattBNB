RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::ReviewsController, type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let!(:booking) { FactoryBot.create(:booking, user_id: user.id) }
  let!(:booking2) { FactoryBot.create(:booking, user_id: user2.id) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'POST /api/v1/review' do

    describe 'successfully' do
      before do
        post_request = post '/api/v1/reviews', params: {
          score: '2',
          body: 'Fantastic host! Fully recommended!',
          host_nickname: 'Joker',
          user_id: user.id,
          booking_id: booking.id,
          host_profile_id: profile2.id
        },
        headers: headers
      end

      it 'creates a review' do
        expect(json_response['message']).to eq 'Successfully created!'
        expect(response.status).to eq 200
      end

      it 'creates review in under 1 ms and with iteration rate of 5000000 per second' do
        expect { post_request }.to perform_under(1).ms.sample(20).times
        expect { post_request }.to perform_at_least(5000000).ips
      end
    end

    describe 'unsuccessfully' do
      it 'Review can not be created without all fields filled in' do
        post '/api/v1/reviews', params: {
          host_nickname: 'Joker',
          user_id: user.id,
          booking_id: booking.id,
          host_profile_id: profile2.id
        },
        headers: headers

        expect(json_response['error']).to eq ["Score can't be blank"]
        expect(response.status).to eq 422
      end

      it 'Review can not be created if body is more than 1000 characters in length' do
        post '/api/v1/reviews', params: {
          score: '2',
          body: 'Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! ',
          host_nickname: 'Joker',
          user_id: user.id,
          booking_id: booking.id,
          host_profile_id: profile2.id
        },
        headers: headers

        expect(json_response['error']).to eq ['Body is too long (maximum is 1000 characters)']
        expect(response.status).to eq 422
      end

      it 'Review can not be created if user is not associated with the booking' do
        post '/api/v1/reviews', params: {
          score: '2',
          body: 'Fantastic host! Fully recommended!',
          host_nickname: 'Joker',
          user_id: user.id,
          booking_id: booking2.id,
          host_profile_id: profile2.id
        },
        headers: headers

        expect(json_response['error']).to eq ['You cannot perform this action!']
        expect(response.status).to eq 422
      end

      it 'Review can not be created if user is not logged in' do
        post '/api/v1/reviews', headers: not_headers
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
  end
end
