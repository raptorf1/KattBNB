RSpec.describe 'GET /api/v1/conversations/id', type: :request do
  let(:messenger) { FactoryBot.create(:user) }
  let(:credentials) { messenger.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_user_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(random_user_credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

  let(:conversation) { FactoryBot.create(:conversation, user1_id: messenger.id) }
  let!(:message) { 2.times { FactoryBot.create(:message, user_id: messenger.id, conversation_id: conversation.id) } }

  describe 'successfully' do
    before do
      Message.last.image.attach(
        io: File.open('spec/fixtures/greece.jpg'),
        filename: 'attachment_amazon_s3.jpg',
        content_type: 'image/jpg'
      )
      get "/api/v1/conversations/#{conversation.id}", headers: headers
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'returns correct conversation' do
      expect(json_response['id']).to eq conversation.id
    end

    it 'returns correct number of messages within the conversation' do
      expect(json_response['message'].count).to eq 2
    end

    it 'has correct number of keys in the response' do
      expect(json_response.count).to eq 3
    end

    it 'has correct keys in the response' do
      expect(json_response).to include('id', 'message', 'hidden')
    end

    it 'has correct number of keys in the response for the message' do
      expect(json_response['message'].first.count).to eq 5
    end

    it 'has correct keys in the response for the message' do
      expect(json_response['message'].first).to include('body', 'created_at', 'user', 'id', 'image')
    end

    it 'has correct number of keys in the response user of the message' do
      expect(json_response['message'].first['user'].count).to eq 1
    end

    it 'has correct keys in the response for the user of the message' do
      expect(json_response['message'].first['user']).to include('nickname')
    end

    it 'has URL in image response if image is attached' do
      expect(json_response['message'].second['image'].include?('http://localhost:3007/rails/active_storage/blobs'))
    end

    it 'has correct filename in image response if image is attached' do
      expect(json_response['message'].second['image'].include?('attachment_amazon_s3.jpg'))
    end
  end

  describe 'unsuccessfully' do
    describe 'if not authenticated' do
      before { get "/api/v1/conversations/#{conversation.id}", headers: unauthenticated_headers }

      it 'with 401 status' do
        expect(response.status).to eq 401
      end

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end

    describe 'if not part of the conversation' do
      before { get "/api/v1/conversations/#{conversation.id}", headers: random_user_headers }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end
    end
  end
end
