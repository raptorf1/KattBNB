RSpec.describe 'GET /api/v1/reviews', type: :request do
  let(:host_profile) { FactoryBot.create(:host_profile) }
  let!(:reviews) { 10.times { FactoryBot.create(:review, host_profile_id: host_profile.id) } }

  describe 'successfully' do
    describe 'according to params passed' do
      before { get "/api/v1/reviews?host_profile_id=#{host_profile.id}" }

      it 'returns correct number of reviews' do
        expect(json_response.count).to eq 10
      end

      it 'returns 200 status' do
        expect(response.status).to eq 200
      end

      it 'returns correct number of keys in the response' do
        expect(json_response.first.count).to eq 9
      end

      it 'returns correct key names in the response' do
        expect(json_response.first).to include(
          'id',
          'score',
          'body',
          'host_reply',
          'host_nickname',
          'host_avatar',
          'user'
        )
      end
    end
  end

  describe 'unsuccessfully' do
    describe 'if no params are passed' do
      before { get '/api/v1/reviews' }

      it 'is expected to return an empty array ' do
        expect(json_response.count).to eq 0
      end
    end
  end
end
