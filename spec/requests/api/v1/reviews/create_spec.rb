RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe Api::V1::ReviewsController, type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let!(:booking) do
    FactoryBot.create(:booking, user_id: user.id, status: 'accepted', dates: [1_590_017_200_000, 1_590_019_100_000])
  end
  let!(:booking2) { FactoryBot.create(:booking, user_id: user2.id, status: 'accepted') }
  let!(:booking3) do
    FactoryBot.create(
      :booking,
      user_id: user.id,
      status: 'accepted',
      dates: [2_590_000_013_752, 2_590_020_013_752, 2_590_040_013_752, 2_590_060_013_752]
    )
  end
  let!(:booking4) do
    FactoryBot.create(:booking, user_id: user.id, status: 'accepted', dates: [1_590_017_200_000, 1_590_019_100_000])
  end
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'POST /api/v1/review' do
    describe 'successfully' do
      before do
        expect(profile2.score).to eq nil
        post '/api/v1/reviews',
             params: {
               score: 2,
               body: 'Fantastic host! Fully recommended!',
               host_nickname: 'Joker',
               user_id: user.id,
               booking_id: booking.id,
               host_profile_id: profile2.id
             },
             headers: headers
      end

      it 'creates a review and updates host profile score' do
        expect(json_response['message']).to eq 'Successfully created!'
        expect(response.status).to eq 200
        profile2.reload
        expect(profile2.score).to eq 2.0
      end

      it 'sends a notification email to the host' do
        expect(Delayed::Job.all.count).to eq 1
        expect(Delayed::Job.first.queue).to eq 'reviews_email_notifications'
      end

      it 'updates host profile score when there are more than 1 reviews' do
        post '/api/v1/reviews',
             params: {
               score: 5,
               body: 'Fantastic host! Fully recommended!',
               host_nickname: 'Joker',
               user_id: user.id,
               booking_id: booking4.id,
               host_profile_id: profile2.id
             },
             headers: headers
        expect(response.status).to eq 200
        profile2.reload
        expect(profile2.score).to eq 3.5
      end

      it 'creates review in under 1 ms and with iteration rate of 2000000 per second' do
        post_request =
          post '/api/v1/reviews',
               params: {
                 score: 2,
                 body: 'Fantastic host! Fully recommended!',
                 host_nickname: 'Joker',
                 user_id: user.id,
                 booking_id: booking.id,
                 host_profile_id: profile2.id
               },
               headers: headers

        expect { post_request }.to perform_under(1).ms.sample(20).times
        expect { post_request }.to perform_at_least(2_000_000).ips
      end
    end

    describe 'unsuccessfully' do
      it 'Review can not be created without all fields filled in' do
        post '/api/v1/reviews',
             params: {
               host_nickname: 'Joker',
               user_id: user.id,
               booking_id: booking.id,
               host_profile_id: profile2.id
             },
             headers: headers

        expect(json_response['error']).to eq ["Score can't be blank", 'Score is not a number', "Body can't be blank"]
        expect(response.status).to eq 422
      end

      it 'Review can not be created if body is more than 1000 characters in length' do
        post '/api/v1/reviews',
             params: {
               score: 2,
               body:
                 'Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! Fantastic host! Fully recommended! ',
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
        post '/api/v1/reviews',
             params: {
               score: 2,
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

      it 'Review can not be created if associated user tries to review an unresolved booking' do
        post '/api/v1/reviews',
             params: {
               score: 2,
               body: 'Fantastic host! Fully recommended!',
               host_nickname: 'Joker',
               user_id: user.id,
               booking_id: booking3.id,
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
