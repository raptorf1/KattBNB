RSpec.describe 'POST /api/v1/conversations', type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:credentials) { user1.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Queen') }

  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }

  let!(:existing_conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'succesfully for new conversation' do
    before { post '/api/v1/conversations', params: { user1_id: user1.id, user2_id: user2.id }, headers: headers }

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with relevant message' do
      expect(json_response['message']).to eq 'Successfully created!'
    end

    it 'with correct ID in the response' do
      expect(json_response['id']).not_to eq existing_conversation.id
    end
  end

  describe 'successfully for existing conversation' do
    before { post '/api/v1/conversations', params: { user1_id: user1.id, user2_id: user3.id }, headers: headers }

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with relevant message' do
      expect(json_response['message']).to eq 'Conversation already exists!'
    end

    it 'with correct ID in the response' do
      expect(json_response['id']).to eq existing_conversation.id
    end
  end

  describe 'unsuccesfully' do
    describe 'if user is not logged in' do
      before { post '/api/v1/conversations', params: { user1_id: user1.id, user2_id: user2.id }, headers: not_headers }

      it 'with relevant error ' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end

    describe 'if user does not exist' do
      before { post '/api/v1/conversations', params: { user1_id: user1.id, user2_id: 10_000 }, headers: headers }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq ['User2 must exist']
      end
    end
  end
end
