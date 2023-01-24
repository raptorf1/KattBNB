RSpec.describe "GET /api/v1/fetch_booking_actions/incoming_stats", type: :request do
  let(:host_profile) { FactoryBot.create(:host_profile) }
  let(:host_credentials) { host_profile.user.create_new_auth_token }
  let(:host_headers) { { HTTP_ACCEPT: "application/json" }.merge!(host_credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_user_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_user_credentials) }

  let!(:upcoming_booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host_profile.user.nickname,
      host_profile_id: host_profile.id,
      status: "accepted",
      paid: false,
      dates: [1, 2, 3, 2_562_889_600_000]
    )
  end

  let!(:history_accepted_booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host_profile.user.nickname,
      host_profile_id: host_profile.id,
      status: "accepted",
      paid: true,
      dates: [4, 5, 6, 1_162_889_600_000]
    )
  end

  let!(:pending_booking) do
    FactoryBot.create(:booking, status: "pending", host_nickname: host_profile.user.nickname, paid: false)
  end

  let!(:history_declined_booking) do
    FactoryBot.create(:booking, status: "declined", host_nickname: host_profile.user.nickname, paid: false)
  end

  let!(:history_cenceled_booking) do
    FactoryBot.create(:booking, status: "canceled", host_nickname: host_profile.user.nickname, paid: false)
  end

  let!(:random_booking) { FactoryBot.create(:booking, status: "pending") }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "when user has host profile" do
      before { get "/api/v1/fetch_booking_actions/incoming_stats", headers: host_headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct booking stats" do
        expect(
          json_response["stats"].to_json
        ).to eq "{\"in_requests\":1,\"in_upcoming\":1,\"in_history\":3,\"in_unpaid\":1}"
      end
    end

    describe "when user has no host profile" do
      before { get "/api/v1/fetch_booking_actions/incoming_stats", headers: random_user_headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with empty collection in the response" do
        expect(json_response.size).to eq 0
      end
    end
  end

  describe "unsuccessfully" do
    describe "if user is not logged in" do
      before { get "/api/v1/fetch_booking_actions/incoming_stats", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
