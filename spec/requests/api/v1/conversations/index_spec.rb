RSpec.describe Api::V1::ConversationsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }
  let(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:user3) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Quinn') }
  let(:credentials3) { user3.create_new_auth_token }
  let(:headers3) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials3) }
  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/conversations' do

    before do
      @conversation1 = FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id)
      @conversation2 = FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id)
    end

    it 'returns 401 response if user not logged in' do
      get '/api/v1/conversations/', headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'returns an empty collection of conversations if no params are passed' do
      get '/api/v1/conversations', headers: headers1
      expect(json_response.count).to eq 0
      expect(Conversation.all.length).to eq 2
    end

    it 'returns 200 response' do
      get '/api/v1/conversations', headers: headers1
      expect(response.status).to eq 200
    end
      
    it 'returns a list of conversations to the involved user' do
      get '/api/v1/conversations', params: {user_id: user1.id}, headers: headers1
      expect(json_response[0]['id']).to eq @conversation1.id
      expect(json_response[1]['id']).to eq @conversation2.id
    end

    it 'returns the last message of the conversation and created_at' do
      msg1 =  FactoryBot.create(:message, user_id: user1.id, conversation_id: @conversation1.id, body: 'Batman, I love you!')
      msg2 =  FactoryBot.create(:message, user_id: user2.id, conversation_id: @conversation1.id, body: 'Joker, u drunk.')
      msg3 =  FactoryBot.create(:message, user_id: user1.id, conversation_id: @conversation1.id, body: "Naw, I promise you, let's be friends!!!")
      
      get '/api/v1/conversations', params: {user_id: user1.id}, headers: headers1
      expect(json_response[0]['msg_body']).to eq msg3.body
      expect(json_response[0]).to include('msg_created')
    end

    it 'does not return a list of conversations to an uninvolved user' do
      get '/api/v1/conversations', params: {user_id: user2.id}, headers: headers3
      expect(json_response.count).to eq 0
      expect(Conversation.all.length).to eq 2
    end
  end
end
