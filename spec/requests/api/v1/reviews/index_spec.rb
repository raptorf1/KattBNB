RSpec.describe 'GET /api/v1/reviews', type: :request do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:booking) { FactoryBot.create(:booking, user_id: user.id) }

  let(:another_user) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner', location: 'Crete') }
  let(:profile_another_user) { FactoryBot.create(:host_profile, user_id: another_user.id) }
  let(:booking2) { FactoryBot.create(:booking, user_id: another_user.id) }

  let!(:review) do
    FactoryBot.create(:review, user_id: user.id, booking_id: booking.id, host_profile_id: profile_another_user.id)
  end

  let!(:review2) do
    FactoryBot.create(:review, user_id: another_user.id, booking_id: booking2.id, host_profile_id: profile_user.id)
  end

  describe 'successfully' do
    it 'returns an empty array if no params are passed' do
      get '/api/v1/reviews'
      expect(json_response.count).to eq 0
    end

    describe 'according to params passed' do
      before { get "/api/v1/reviews?host_profile_id=#{profile_another_user.id}" }

      it 'returns correct number of reviews' do
        expect(json_response.count).to eq 1
      end

      it 'returns 200 status' do
        expect(response.status).to eq 200
      end

      it 'returns correct review' do
        expect(json_response.first['id']).to eq review.id
      end

      it 'returns correct number of keys in the response' do
        expect(json_response.first.count).to eq 9
      end

      it 'returns correct key names in the response' do
        expect(json_response.first).to include('id', 'score', 'body', 'host_reply', 'host_nickname', 'host_avatar', 'user')
      end
    end
  end
end
