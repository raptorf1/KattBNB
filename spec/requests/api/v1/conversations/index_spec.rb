RSpec.describe "GET /api/v1/conversations", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let!(:conversations) { 2.times { FactoryBot.create(:conversation, user1_id: user.id) } }
  let!(:message) { FactoryBot.create(:message, user_id: user.id, conversation_id: Conversation.first.id, body: "") }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    before { get "/api/v1/conversations", headers: headers }

    it "with correct number of conversations in the response" do
      expect(json_response.count).to eq 2
    end

    it "with fixed text if last message is an image attachment" do
      expect(json_response.first["msg_body"]).to eq "Image attachment"
    end

    it "with timestamp of last message" do
      expect(json_response.first).to include("msg_created")
    end
  end

  describe "unsuccessfulyy" do
    describe "if user not logged in" do
      before { get "/api/v1/conversations/", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
