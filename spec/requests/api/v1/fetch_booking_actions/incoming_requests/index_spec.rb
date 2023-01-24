RSpec.describe "GET /api/v1/fetch_booking_actions/incoming_requests", type: :request do
  let(:host_profile) { FactoryBot.create(:host_profile) }
  let(:host_credentials) { host_profile.user.create_new_auth_token }
  let(:host_headers) { { HTTP_ACCEPT: "application/json" }.merge!(host_credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_user_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_user_credentials) }

  let!(:booking_1) { FactoryBot.create(:booking, host_nickname: host_profile.user.nickname, status: "pending") }
  let!(:booking_2) { FactoryBot.create(:booking, host_nickname: host_profile.user.nickname, status: "pending") }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "when host profile exists" do
      before { get "/api/v1/fetch_booking_actions/incoming_requests", headers: host_headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct amount of bookings" do
        expect(json_response.size).to eq 2
      end

      it "with correct number of keys" do
        expect(json_response.first.size).to eq 22
      end

      it "with correct names of keys" do
        expect(json_response.first).to include(
          "id",
          "number_of_cats",
          "dates",
          "status",
          "host_id",
          "host_profile_id",
          "host_profile_score",
          "host_location",
          "host_nickname",
          "message",
          "price_total",
          "host_message",
          "host_avatar",
          "host_description",
          "host_full_address",
          "host_real_lat",
          "host_real_long",
          "created_at",
          "updated_at",
          "user_id",
          "review_id",
          "user"
        )
      end

      it "with correct number of keys for user" do
        expect(json_response.first["user"].size).to eq 4
      end

      it "with correct names of keys for user" do
        expect(json_response.first["user"]).to include("nickname", "location", "id", "profile_avatar")
      end
    end

    describe "when host profile does not exist" do
      before { get "/api/v1/fetch_booking_actions/incoming_requests", headers: random_user_headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with empty collection as response" do
        expect(json_response.size).to eq 0
      end
    end
  end

  describe "unsuccessfully" do
    describe "if user is not logged in" do
      before { get "/api/v1/fetch_booking_actions/incoming_requests", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
