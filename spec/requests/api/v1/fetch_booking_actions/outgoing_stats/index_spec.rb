RSpec.describe "GET /api/v1/fetch_booking_actions/outgoing_stats", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(user_credentials) }

  let!(:upcoming_booking) do
    FactoryBot.create(:booking, user_id: user.id, status: "accepted", dates: [1, 2, 3, 2_562_889_600_000])
  end

  let!(:history_accepted_booking) do
    FactoryBot.create(:booking, user_id: user.id, status: "accepted", dates: [4, 5, 6, 1_162_889_600_000])
  end

  let!(:pending_booking) { FactoryBot.create(:booking, status: "pending", user_id: user.id) }
  let!(:history_declined_booking) { FactoryBot.create(:booking, status: "declined", user_id: user.id) }
  let!(:history_cenceled_booking) { FactoryBot.create(:booking, status: "canceled", user_id: user.id) }
  let!(:random_booking) { FactoryBot.create(:booking, status: "pending") }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    before { get "/api/v1/fetch_booking_actions/outgoing_stats", headers: user_headers }

    it "with 200 status" do
      expect(response.status).to eq 200
    end

    it "with correct booking stats" do
      expect(json_response["stats"].to_json).to eq "{\"out_requests\":1,\"out_upcoming\":1,\"out_history\":3}"
    end
  end

  describe "unsuccessfully" do
    describe "if user is not logged in" do
      before { get "/api/v1/fetch_booking_actions/outgoing_stats", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
