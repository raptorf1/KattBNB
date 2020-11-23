RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::ReviewsController, type: :request do
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let!(:another_user) { FactoryBot.create(:user, email: 'felix@craft.com', nickname: 'Planner', location: 'Crete') }
  let!(:booking) { FactoryBot.create(:booking, user_id: user.id) }
  let!(:booking2) { FactoryBot.create(:booking, user_id: user.id) }
  let!(:booking3) { FactoryBot.create(:booking, user_id: another_user.id) }
  let!(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let!(:profile_another_user) { FactoryBot.create(:host_profile, user_id: another_user.id) }
  let!(:review) { FactoryBot.create(:review, user_id: user.id, booking_id: booking.id, host_profile_id: profile_another_user.id) }
  let!(:review2) { FactoryBot.create(:review, user_id: user.id, booking_id: booking2.id, host_profile_id: profile_another_user.id) }
  let!(:review3) { FactoryBot.create(:review, user_id: another_user.id, booking_id: booking3.id, host_profile_id: profile_user.id) }

  describe 'GET /api/v1/reviews' do

    it 'returns an empty array if no params are passed' do
      get '/api/v1/reviews'
      expect(json_response.count).to eq 0
      expect(Review.all.length).to eq 3
    end

    it 'returns a collection of reviews if correct host profile params are passed' do
      get "/api/v1/reviews?host_profile_id=#{profile_another_user.id}"
      expect(response.status).to eq 200
      expect(json_response.count).to eq 2
    end

    it 'returns a collection of reviews if correct host profile params are passed' do
      get "/api/v1/reviews?host_profile_id=#{profile_user.id}"
      expect(response.status).to eq 200
      expect(json_response.count).to eq 1
    end

    it 'has correct keys in the response' do
      get "/api/v1/reviews?host_profile_id=#{profile_another_user.id}"
      expect(json_response[0]).to include('id')
      expect(json_response[0]).to include('score')
      expect(json_response[0]).to include('body')
      expect(json_response[0]).to include('host_reply')
      expect(json_response[0]).to include('host_nickname')
      expect(json_response[0]).to include('host_avatar')
      expect(json_response[0]).to include('created_at')
      expect(json_response[0]).to include('updated_at')
      expect(json_response[0]).to include('user')
      expect(json_response[0].count).to eq 9
    end

    it 'fetches collection of reviews in under 1 ms and with iteration rate of at least 1000000 per second' do
      get_request = get "/api/v1/reviews?host_profile_id=#{profile_another_user.id}"
      expect { get_request }.to perform_under(1).ms.sample(20).times
      expect { get_request }.to perform_at_least(1000000).ips
    end
  end

end
