RSpec.describe "PATCH /api/v1/reviews/id", type: :request do
  let(:host) { FactoryBot.create(:user, nickname: "Harley Quinn") }
  let(:host_credentials) { host.create_new_auth_token }
  let(:host_headers) { { HTTP_ACCEPT: "application/json" }.merge!(host_credentials) }
  let(:host_profile) { FactoryBot.create(:host_profile, user_id: host.id) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  let(:review) do
    FactoryBot.create(:review, host_nickname: "Harley Quinn", host_reply: nil, host_profile_id: host_profile.id)
  end

  let(:random_review) { FactoryBot.create(:review) }

  describe "successfully " do
    describe "when user and host exist" do
      before do
        patch "/api/v1/reviews/#{review.id}", params: { host_reply: "Thanks!" }, headers: host_headers
        review.reload
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Successfully updated!"
      end

      it "with correct host reply recorded" do
        expect(review.host_reply).to eq "Thanks!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end

    describe "even if the user who wrote the review has deleted their account" do
      before do
        review.update_attribute(:user_id, nil)
        review.update_attribute(:booking_id, nil)
        patch "/api/v1/reviews/#{review.id}", params: { host_reply: "Thanks a lot!" }, headers: host_headers
        review.reload
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct host reply" do
        expect(review.host_reply).to eq "Thanks a lot!"
      end
    end
  end

  describe "unsuccessfully" do
    describe "if host is not logged in" do
      before do
        patch "/api/v1/reviews/#{review.id}", params: { host_reply: "Thanks a lot!" }, headers: unauthenticated_headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "if host tries to update review they are not part of" do
      before do
        patch "/api/v1/reviews/#{random_review.id}", params: { host_reply: "Thanks a lot!" }, headers: host_headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You cannot perform this action!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if review has already been updated" do
      before do
        review.update(host_reply: "Already updated!")
        patch "/api/v1/reviews/#{review.id}", params: { host_reply: "Thanks a lot!" }, headers: host_headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["A reply already exists for this review!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if reply message is over 1000 characters long" do
      before do
        patch "/api/v1/reviews/#{review.id}", params: { host_reply: "Thanks a lot!" * 80 }, headers: host_headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["Your message cannot exceed 1000 characters!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end
  end
end
