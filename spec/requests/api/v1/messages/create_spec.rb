RSpec.describe Api::V1::MessagesController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Queen') }
  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: "application/json" }.merge!(credentials1) }
  let(:credentials3) { user3.create_new_auth_token }
  let(:headers3) { { HTTP_ACCEPT: "application/json" }.merge!(credentials3) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'POST /api/v1/conversations/id/messages' do

    describe 'successfully' do
      before do
        post "/api/v1/conversations/#{conversation.id}/messages", params: {
          user_id: user1.id,
          conversation_id: conversation.id,
          body: 'Batman, u dedd.'
        },
        headers: headers1
      end

      it 'creates a new message' do
        expect(json_response['message']).to eq 'Successfully created'
        expect(json_response['body']).to eq Message.last.body
        expect(response.status).to eq 200
      end
    end

    describe 'unsuccessfully' do
      it 'Message cannot be created if user is not logged in' do
        post "/api/v1/conversations/#{conversation.id}/messages", params: {
          user_id: user1.id,
          conversation_id: conversation.id,
          body: 'Batman, u dedd.'
        },
        headers: not_headers
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'Message cannot be created if user is not associated with the relevant conversation' do
        post "/api/v1/conversations/#{conversation.id}/messages", params: {
          user_id: user3.id,
          conversation_id: conversation.id,
          body: 'Joker, fuck you!'
        },
        headers: headers3
        expect(json_response['error']).to eq 'You cannot perform this action'
      end
    end
  end
end
