RSpec.describe Api::V1::ConversationsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Quinn') }
  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }
  let(:credentials1) { user1.create_new_auth_token }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: "application/json" }.merge!(credentials1) }
  let(:headers2) { { HTTP_ACCEPT: "application/json" }.merge!(credentials2) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'GET /api/v1/conversations' do

    describe 'successfully' do
      before do
        FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation1.id, body: 'Hello, Harley!')
        FactoryBot.create(:message, user_id: user2.id, conversation_id: conversation1.id, body: 'Hello, Joker!')
        get "/api/v1/conversations/#{conversation1.id}", headers: headers1
      end

      it 'views a specific conversation' do
        expect(json_response['id']).to eq conversation1.id
        expect(response.status).to eq 200
      end

      it 'views messages within a conversation' do
        expect(json_response['message'][0]['body']).to eq 'Hello, Harley!'
        expect(json_response['message'][1]['body']).to eq 'Hello, Joker!'
      end

      it 'has correct keys in the response' do
        expect(json_response).to include('id')
        expect(json_response).to include('message')
        expect(json_response).to include('hidden')
        expect(json_response.count).to eq 3
        expect(json_response['message'][0]).to include('body')
        expect(json_response['message'][0]).to include('created_at')
        expect(json_response['message'][0]).to include('user')
        expect(json_response['message'][0]).to include('id')
        expect(json_response['message'][0].count).to eq 4
        expect(json_response['message'][0]['user']).to include('nickname')
        expect(json_response['message'][0]['user'].count).to eq 1
      end
    end

    describe 'unsuccessfully' do
      it 'cannot see conversation if not logged in' do
        get "/api/v1/conversations/#{conversation1.id}", headers: not_headers
        expect(response.status).to eq 401
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'cannot see conversation that she is not a part of' do
        get "/api/v1/conversations/#{conversation2.id}", headers: headers2
        expect(response.status).to eq 422
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end
    end
  end
end
