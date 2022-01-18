RSpec.describe 'GET /api/v1/conversations', type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }

  let(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }

  let(:user3) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Quinn') }
  let(:credentials3) { user3.create_new_auth_token }
  let(:headers3) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials3) }

  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    describe 'when no params exist in the request' do
      before { get '/api/v1/conversations', headers: headers1 }

      it 'with empty response' do
        expect(json_response.count).to eq 0
      end

      it 'with 200 status' do
        expect(response.status).to eq 200
      end
    end

    describe 'when params exist in the request' do
      before do
        FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation1.id, body: 'Batman, I love you!')
        FactoryBot.create(:message, user_id: user2.id, conversation_id: conversation1.id, body: 'Joker, u drunk.')
        FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation1.id, body: '')
        get '/api/v1/conversations', params: { user_id: user1.id }, headers: headers1
      end

      it 'with correct number of conversations in the response' do
        expect(json_response.count).to eq 2
      end

      it 'with fixed text if last message is an image attachment' do
        expect(json_response.first['msg_body']).to eq 'Image attachment'
      end

      it 'with timestamp of last message' do
        expect(json_response.first).to include('msg_created')
      end
    end
  end

  describe 'unsuccessfulyy' do
    describe 'if user not logged in' do
      before { get '/api/v1/conversations/', headers: not_headers }

      it 'with 401 status' do
        expect(response.status).to eq 401
      end

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end

    describe 'if user not part of the conversation' do
      before { get '/api/v1/conversations', params: { user_id: user2.id }, headers: headers3 }

      it 'with empty response' do
        expect(json_response.count).to eq 0
      end
    end
  end
end
