RSpec.describe 'POST /api/v1/review', type: :request do
  let(:reviewer) { FactoryBot.create(:user) }
  let(:credentials) { reviewer.create_new_auth_token }
  let(:authenticated_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:past_booking_1) do
    FactoryBot.create(:booking, user_id: reviewer.id, status: 'accepted', dates: [1_590_017_200_000, 1_590_019_100_000])
  end

  let(:past_booking_2) do
    FactoryBot.create(:booking, user_id: reviewer.id, status: 'accepted', dates: [1_590_017_200_000, 1_590_019_100_000])
  end

  let(:future_booking) do
    FactoryBot.create(
      :booking,
      user_id: reviewer.id,
      status: 'accepted',
      dates: [2_590_000_013_752, 2_590_020_013_752, 2_590_040_013_752, 2_590_060_013_752]
    )
  end

  let(:host) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:host_profile) { FactoryBot.create(:host_profile, user_id: host.id, score: 0) }
  let(:random_booking) { FactoryBot.create(:booking, user_id: host.id, status: 'accepted') }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  def post_request(req_score, req_body, req_booking)
    post '/api/v1/reviews',
         params: {
           score: req_score,
           body: req_body,
           host_nickname: 'Joker',
           user_id: reviewer.id,
           booking_id: req_booking,
           host_profile_id: host_profile.id
         },
         headers: authenticated_headers
  end

  describe 'successfully' do
    before do
      post_request(2, 'Fantastic host! Fully recommended!', past_booking_1.id)
      host_profile.reload
    end

    it 'creates a review with relevant message' do
      expect(json_response['message']).to eq 'Successfully created!'
    end

    it 'creates a review with 200 status' do
      expect(response.status).to eq 200
    end

    it 'updates host profile score' do
      expect(host_profile.score).to eq 2.0
    end

    it 'queues a notification email to the host' do
      expect(Delayed::Job.all.count).to eq 1
    end

    it 'sends a notification email to the host' do
      expect(Delayed::Job.first.queue).to eq 'reviews_email_notifications'
    end
  end

  describe 'unsuccessfully' do
    describe 'if not all fields are filled in' do
      before { post_request('', '', past_booking_1.id) }

      it 'with relevant error' do
        expect(json_response['error']).to eq ["Score can't be blank", 'Score is not a number', "Body can't be blank"]
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end
    end

    it 'with relevant error if body is more than 1000 characters in length' do
      post_request(2, 'Fantastic host! Fully recommended!' * 100, past_booking_1.id)
      expect(json_response['error']).to eq ['Body is too long (maximum is 1000 characters)']
    end

    it 'with relevant error if user is not associated with the booking' do
      post_request(2, 'Fantastic host! Fully recommended!', random_booking.id)
      expect(json_response['error']).to eq ['You cannot perform this action!']
    end

    it 'with relevant error if associated user tries to review a future booking' do
      post_request(2, 'Fantastic host! Fully recommended!', future_booking.id)
      expect(json_response['error']).to eq ['You cannot perform this action!']
    end

    it 'with relevant error if user is not logged in' do
      post '/api/v1/reviews', headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
