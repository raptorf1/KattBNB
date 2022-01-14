RSpec.describe 'GET /api/v1/reviews', type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }
  let(:booking1) { FactoryBot.create(:booking, user_id: user1.id) }

  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Quinn') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let(:booking2) { FactoryBot.create(:booking, user_id: user2.id) }

  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:profile3) { FactoryBot.create(:host_profile, user_id: user3.id) }

  let(:review1) { FactoryBot.create(:review, user_id: user1.id, host_profile_id: profile2.id, booking_id: booking1.id) }
  let(:review2) { FactoryBot.create(:review, user_id: user2.id, host_profile_id: profile3.id, booking_id: booking2.id) }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    before { get "/api/v1/reviews/#{review1.id}", headers: headers1 }

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with correct review id in the response' do
      expect(json_response['id']).to eq review1.id
    end

    it 'with correct number of keys in the response' do
      expect(json_response.count).to eq 9
    end

    it 'with correct keys in the response' do
      expect(json_response).to include('id', 'score', 'body', 'host_reply', 'host_nickname', 'host_avatar', 'user')
    end
  end

  describe 'unsuccessfully' do
    it 'with relevant error message if not logged in' do
      get "/api/v1/reviews/#{review1.id}", headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'with 401 status if not logged in' do
      get "/api/v1/reviews/#{review1.id}", headers: not_headers
      expect(response.status).to eq 401
    end

    it 'with relevant error message if not part of the review' do
      get "/api/v1/reviews/#{review1.id}", headers: headers2
      expect(json_response['error']).to eq ['You cannot perform this action!']
    end

    it 'with 422 status if not part of the review' do
      get "/api/v1/reviews/#{review1.id}", headers: headers2
      expect(response.status).to eq 422
    end
  end
end
