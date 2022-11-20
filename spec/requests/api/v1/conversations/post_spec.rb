RSpec.describe "POST /api/v1/conversations", type: :request do
  let(:messenger) { FactoryBot.create(:user) }
  let(:credentials) { messenger.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:new_friend) { FactoryBot.create(:user) }
  let(:old_friend) { FactoryBot.create(:user) }
  let!(:existing_conversation) { FactoryBot.create(:conversation, user1_id: messenger.id, user2_id: old_friend.id) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "succesfully" do
    describe "for new conversation" do
      before do
        post "/api/v1/conversations", params: { user1_id: messenger.id, user2_id: new_friend.id }, headers: headers
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Successfully created!"
      end

      it "with correct ID in the response" do
        expect(json_response["id"]).not_to eq existing_conversation.id
      end
    end

    describe "for existing conversation" do
      before do
        post "/api/v1/conversations", params: { user1_id: messenger.id, user2_id: old_friend.id }, headers: headers
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Conversation already exists!"
      end

      it "with correct ID in the response" do
        expect(json_response["id"]).to eq existing_conversation.id
      end
    end
  end

  describe "unsuccesfully" do
    describe "if user is not logged in" do
      before do
        post "/api/v1/conversations",
             params: {
               user1_id: messenger.id,
               user2_id: new_friend.id
             },
             headers: unauthenticated_headers
      end

      it "with relevant error " do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end

    describe "if user does not exist" do
      before { post "/api/v1/conversations", params: { user1_id: messenger.id, user2_id: 10_000 }, headers: headers }

      it "with 422 status" do
        expect(response.status).to eq 422
      end

      it "with relevant error" do
        expect(json_response["error"]).to eq ["User2 must exist"]
      end
    end
  end
end
