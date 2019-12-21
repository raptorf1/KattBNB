RSpec.describe Api::V1::ConversationsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Queen') }
  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }
  let(:credentials) { user1.create_new_auth_token }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let(:headers2) { { HTTP_ACCEPT: "application/json" }.merge!(credentials2) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'GET /api/v1/conversations' do

    describe 'successfully' do
      before do
        get "/api/v1/conversations/#{conversation1.id}",
        headers: headers
      end

      it 'views a specific conversation' do
        expect(json_response['id']).to eq conversation1.id
        expect(response.status).to eq 200
      end
    end

    describe 'unsuccessfully' do
      it 'Cannot see conversation if not logged in' do
        get '/api/v1/conversations', headers: not_headers
        expect(response.status).to eq 401
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'Cannot see conversation that she is not a part of' do
        get "/api/v1/conversations/#{conversation2.id}", headers: headers2
        expect(response.status).to eq 422
        expect(json_response['error']).to eq 'You cannot perform this action'
      end
    end
  end
end