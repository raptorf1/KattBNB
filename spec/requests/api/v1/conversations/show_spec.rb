RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

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
        Message.last.image.attach(io: File.open('spec/fixtures/greece.jpg'), filename: 'attachment_amazon_s3.jpg', content_type: 'image/jpg')
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
        expect(json_response['message'][0]).to include('image')
        expect(json_response['message'][0].count).to eq 5
        expect(json_response['message'][0]['user']).to include('nickname')
        expect(json_response['message'][0]['user'].count).to eq 1
      end

      it 'has URL and correct filename in image response if image is attached' do
        expect(json_response['message'][0]['image']).to eq nil
        expect(json_response['message'][1]['image'].include?('http://localhost:3007/rails/active_storage/blobs'))
        expect(json_response['message'][1]['image'].include?('attachment_amazon_s3.jpg'))
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

    describe 'performance wise' do
      before do
        FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation1.id, body: 'Hello, Harley!')
        FactoryBot.create(:message, user_id: user2.id, conversation_id: conversation1.id, body: 'Hello, Joker!')
        Message.last.image.attach(io: File.open('spec/fixtures/greece.jpg'), filename: 'attachment_amazon_s3.jpg', content_type: 'image/jpg')
      end

      it 'fetches specific conversation in under 1 ms and with iteration rate of 5000000 per second' do
        get_request = get "/api/v1/conversations/#{conversation1.id}", headers: headers1
        expect { get_request }.to perform_under(1).ms.sample(20).times
        expect { get_request }.to perform_at_least(5000000).ips
      end
    end
  end
end
