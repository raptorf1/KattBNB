RSpec.describe "GET /api/v1/fetch_booking_actions/outgoing_upcoming", type: :request do
  let(:cat_owner) { FactoryBot.create(:user) }
  let(:cat_owner_credentials) { cat_owner.create_new_auth_token }
  let(:cat_owner_headers) { { HTTP_ACCEPT: "application/json" }.merge!(cat_owner_credentials) }

  let!(:booking_no_appear) { FactoryBot.create(:booking, user_id: cat_owner.id, status: "accepted", dates: [1, 2, 3]) }

  let!(:booking_to_appear) do
    FactoryBot.create(:booking, user_id: cat_owner.id, status: "accepted", dates: [4, 2_562_889_600_000])
  end

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    before { get "/api/v1/fetch_booking_actions/outgoing_upcoming", headers: cat_owner_headers }

    it "with 200 status" do
      expect(response.status).to eq 200
    end

    it "with correct amount of bookings" do
      expect(json_response.size).to eq 1
    end

    it "with correct booking" do
      expect(json_response.first["id"]).to eq booking_to_appear.id
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

  describe "unsuccessfully" do
    describe "if user is not logged in" do
      before { get "/api/v1/fetch_booking_actions/outgoing_upcoming", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
