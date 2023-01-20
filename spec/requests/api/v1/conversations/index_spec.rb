RSpec.describe "GET /api/v1/conversations", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let!(:conversation_1) do
    FactoryBot.create(:conversation, user1_id: user.id, created_at: "Thu, 01 Jan 2023 00:01:00 UTC +00:00")
  end
  let!(:conversation_2) do
    FactoryBot.create(:conversation, user2_id: user.id, created_at: "Thu, 01 Jan 2023 00:02:00 UTC +00:00")
  end
  let!(:conversation_3) do
    FactoryBot.create(
      :conversation,
      user1_id: user.id,
      hidden: user.id,
      created_at: "Thu, 01 Jan 2023 00:03:00 UTC +00:00"
    )
  end

  let!(:message_1) do
    FactoryBot.create(
      :message,
      user_id: user.id,
      conversation_id: conversation_1.id,
      body: "Happy new year!!!",
      created_at: "Thu, 01 Jan 2023 00:06:00 UTC +00:00"
    )
  end
  let!(:message_2) do
    FactoryBot.create(
      :message,
      user_id: user.id,
      conversation_id: conversation_2.id,
      body: "",
      created_at: Time.current
    )
  end

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "when messages exist for both conversations" do
      before { get "/api/v1/conversations", headers: headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of conversations in the response" do
        expect(json_response.count).to eq 2
      end

      it "with correct order of conversations in the response (the one with the latest created message appears first)" do
        expect(json_response.first["id"]).to eq conversation_2.id
      end

      it "with hidden conversation not in the response" do
        json_response.each { |conversation| expect(conversation["id"]).to_not eq conversation_3.id }
      end

      it "with fixed text if last message is an image attachment" do
        expect(json_response.first["msg_body"]).to eq "Image attachment"
      end

      it "with timestamp of last message" do
        expect(json_response.first).to include("msg_created")
      end
    end

    describe "when messages do not exist for both conversations" do
      before do
        message_1.destroy
        message_2.destroy
        conversation_1.reload
        conversation_2.reload
        get "/api/v1/conversations", headers: headers
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of conversations in the response" do
        expect(json_response.count).to eq 2
      end

      it "with correct order of conversations in the response (the one latest created appears first)" do
        expect(json_response.first["id"]).to eq conversation_2.id
      end

      it "with no messages in either conversation in the response" do
        json_response.each { |conversation| expect(conversation["msg_body"]).to eq nil }
      end

      it "with hidden conversation not in the response" do
        json_response.each { |conversation| expect(conversation["id"]).to_not eq conversation_3.id }
      end
    end

    describe "when message exists only for one conversation" do
      before do
        message_2.destroy
        conversation_2.reload
        get "/api/v1/conversations", headers: headers
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of conversations in the response" do
        expect(json_response.count).to eq 2
      end

      it "with correct order of conversations in the response (the one with the latest action appears first)" do
        expect(json_response.first["id"]).to eq conversation_1.id
      end

      it "with hidden conversation not in the response" do
        json_response.each { |conversation| expect(conversation["id"]).to_not eq conversation_3.id }
      end
    end
  end

  describe "unsuccessfully" do
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
