RSpec.describe "PATCH /api/v1/conversations/id", type: :request do
  let(:user_1) { FactoryBot.create(:user) }
  let(:credentials) { user_1.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:user_2) { FactoryBot.create(:user) }

  let(:user_3) { FactoryBot.create(:user) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  let!(:conversation_1) { FactoryBot.create(:conversation, user1_id: user_1.id, user2_id: user_2.id, hidden: nil) }

  let!(:conversation_2) do
    FactoryBot.create(:conversation, user1_id: user_1.id, user2_id: user_3.id, hidden: user_3.id)
  end

  let!(:random_conversation) { FactoryBot.create(:conversation) }

  describe "succesfully" do
    describe "hides conversation from one user" do
      before do
        patch "/api/v1/conversations/#{conversation_1.id}", params: { hidden: user_1.id }, headers: headers
        conversation_1.reload
      end

      it "with 200 status updates hidden field of certain conversation if action comes from associated host" do
        expect(response.status).to eq 200
      end

      it "with relevant message updates hidden field of certain conversation if action comes from associated host" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with correct user id in the hidden field of the updated conversation" do
        expect(conversation_1.hidden).to eq user_1.id
      end
    end

    describe "deletes conversation when second user hides it" do
      before { patch "/api/v1/conversations/#{conversation_2.id}", params: { hidden: user_1.id }, headers: headers }

      it "with 204 status" do
        expect(response.status).to eq 204
      end

      it "and leaves correct number of conversations in the database" do
        expect(Conversation.all.length).to eq 2
      end

      it "and leaves the correct conversations in the database" do
        expect(Conversation.all).not_to include conversation_2.id
      end
    end
  end

  describe "unsuccessfully" do
    describe "for an unassociated user" do
      before do
        patch "/api/v1/conversations/#{random_conversation.id}", params: { hidden: user_1.id }, headers: headers
      end

      it "with 422 status" do
        expect(response.status).to eq 422
      end

      it "with relevant error" do
        expect(json_response["error"]).to eq "You cannot perform this action!"
      end
    end

    describe "if not logged in" do
      before { patch "/api/v1/conversations/#{conversation_1.id}", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
