RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::ReviewsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Quinn') }
  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:profile1) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let!(:profile2) { FactoryBot.create(:host_profile, user_id: user3.id) }
  let!(:booking1) { FactoryBot.create(:booking, user_id: user1.id) }
  let!(:booking2) { FactoryBot.create(:booking, user_id: user2.id) }
  let(:review1) { FactoryBot.create(:review, user_id: user1.id, host_profile_id: profile1.id, booking_id: booking1.id) }
  let(:review2) { FactoryBot.create(:review, user_id: user2.id, host_profile_id: profile2.id, booking_id: booking2.id) }
  let(:credentials1) { user1.create_new_auth_token }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: "application/json" }.merge!(credentials1) }
  let(:headers2) { { HTTP_ACCEPT: "application/json" }.merge!(credentials2) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'GET /api/v1/reviews' do

    describe 'successfully' do
      before do
        get "/api/v1/reviews/#{review1.id}", headers: headers1
      end

      it 'views a specific review' do
        expect(json_response['id']).to eq review1.id
        expect(response.status).to eq 200
      end

      it 'has correct keys in the response' do
        expect(json_response).to include('id')
        expect(json_response).to include('score')
        expect(json_response).to include('body')
        expect(json_response).to include('host_reply')
        expect(json_response).to include('host_nickname')
        expect(json_response).to include('host_avatar')
        expect(json_response).to include('created_at')
        expect(json_response).to include('updated_at')
        expect(json_response).to include('user')
        expect(json_response.count).to eq 9
      end
    end

    describe 'unsuccessfully' do
      it 'cannot see review if not logged in' do
        get "/api/v1/reviews/#{review1.id}", headers: not_headers
        expect(response.status).to eq 401
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'cannot see review that she is not a part of' do
        get "/api/v1/reviews/#{review1.id}", headers: headers2
        expect(response.status).to eq 422
        expect(json_response['error']).to eq ['You cannot perform this action!']
      end
    end

    describe 'performance wise' do
      it 'fetches specific review in under 1 ms and with iteration rate of 5000000 per second' do
        get_request = get "/api/v1/reviews/#{review1.id}", headers: headers1
        expect { get_request }.to perform_under(1).ms.sample(20).times
        expect { get_request }.to perform_at_least(5000000).ips
      end
    end
  end
end
