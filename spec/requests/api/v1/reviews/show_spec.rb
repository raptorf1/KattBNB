RSpec.describe "GET /api/v1/reviews", type: :request do
  let(:reviewer) { FactoryBot.create(:user, email: "chaos@thestreets.com", nickname: "Joker") }
  let(:reviewer_credentials) { reviewer.create_new_auth_token }
  let(:reviewer_headers) { { HTTP_ACCEPT: "application/json" }.merge!(reviewer_credentials) }

  let(:host_profile) { FactoryBot.create(:host_profile) }
  let(:host_credentials) { host_profile.user.create_new_auth_token }
  let(:host_headers) { { HTTP_ACCEPT: "application/json" }.merge!(host_credentials) }

  let(:booking) { FactoryBot.create(:booking, user_id: reviewer.id) }
  let(:review) do
    FactoryBot.create(:review, host_profile_id: host_profile.id, user_id: reviewer.id, booking_id: booking.id)
  end

  let(:other_credentials) { FactoryBot.create(:user).create_new_auth_token }
  let(:other_headers) { { HTTP_ACCEPT: "application/json" }.merge!(other_credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "for reviewer" do
      before { get "/api/v1/reviews/#{review.id}", headers: reviewer_headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct review id in the response" do
        expect(json_response["id"]).to eq review.id
      end

      it "with correct number of keys in the response" do
        expect(json_response.count).to eq 9
      end

      it "with correct keys in the response" do
        expect(json_response).to include("id", "score", "body", "host_reply", "host_nickname", "host_avatar", "user")
      end
    end

    describe "for host" do
      before { get "/api/v1/reviews/#{review.id}", headers: host_headers }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct review id in the response" do
        expect(json_response["id"]).to eq review.id
      end

      it "with correct number of keys in the response" do
        expect(json_response.count).to eq 9
      end

      it "with correct keys in the response" do
        expect(json_response).to include("id", "score", "body", "host_reply", "host_nickname", "host_avatar", "user")
      end
    end
  end

  describe "unsuccessfully" do
    describe "if not logged in" do
      before { get "/api/v1/reviews/#{review.id}", headers: unauthenticated_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "if not part of the review" do
      before { get "/api/v1/reviews/#{review.id}", headers: other_headers }

      it "with relevant error" do
        expect(json_response["error"]).to eq ["You cannot perform this action!"]
      end

      it "with 422 status" do
        expect(response.status).to eq 422
      end
    end
  end
end
