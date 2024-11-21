RSpec.describe "GET /api/v1/fetch_booking_actions/host_unavailable_dates", type: :request do
  let(:host_profile) { FactoryBot.create(:host_profile) }
  let(:host_credentials) { host_profile.user.create_new_auth_token }
  let(:host_headers) { { HTTP_ACCEPT: "application/json" }.merge!(host_credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_user_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_user_credentials) }

  let!(:booking_1) do
    FactoryBot.create(
      :booking,
      host_profile_id: host_profile.id,
      status: "accepted",
      dates: [1, 2, 3, 2_562_889_600_000]
    )
  end

  let!(:booking_2) do
    FactoryBot.create(
      :booking,
      host_profile_id: host_profile.id,
      status: "accepted",
      dates: [4, 5, 6, 2_462_889_600_000]
    )
  end

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "when host profile exists" do
      before { get "/api/v1/fetch_booking_actions/host_unavailable_dates", headers: host_headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with sorted collection of booking dates" do
        expect(json_response).to eq [1, 2, 3, 4, 5, 6, 2_462_889_600_000, 2_562_889_600_000]
      end
    end

    describe "when host profile does not exist" do
      before { get "/api/v1/fetch_booking_actions/host_unavailable_dates", headers: random_user_headers }

      it "with 204 status" do
        expect(response.status).to eq 204
      end

      it "with empty response body" do
        expect(response.body).to eq ""
      end
    end
  end

  describe "unsuccessfully" do
    describe "if user is not logged in" do
      before { get "/api/v1/fetch_booking_actions/host_unavailable_dates", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
