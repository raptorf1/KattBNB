RSpec.describe Api::V1::ConversationsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Queen') }
  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }
  let(:credentials) { user1.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'POST /api/v1/conversations' do

    describe 'successfully' do
      before do
        post '/api/v1/conversations', params: {
          user1_id: user1.id,
          user2_id: user2.id
        },
        headers: headers
      end

      it 'creates a new conversation' do
        expect(json_response['message']).to eq 'Successfully created'
        expect(json_response['id']).to eq Conversation.last.id
        expect(response.status).to eq 200
      end

      it 'returns the id of an existing conversation' do
        post '/api/v1/conversations', params: {
          user1_id: user1.id,
          user2_id: user3.id
        }, 
        headers: headers

        expect(json_response['message']).to eq 'Conversation already exists'
        expect(json_response['id']).to eq conversation.id
        expect(response.status).to eq 200
      end
    end

    describe 'unsuccessfully' do
      it 'Conversation cannot be created if user is not logged in' do
        post '/api/v1/conversations', params: {
          user1_id: user1.id,
          user2_id: user2.id
        },
        headers: not_headers
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
  end
end
