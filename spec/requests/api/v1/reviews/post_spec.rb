RSpec.describe "POST /api/v1/review", type: :request do
  let(:reviewer) { FactoryBot.create(:user) }
  let(:credentials) { reviewer.create_new_auth_token }
  let(:authenticated_headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:past_booking) do
    FactoryBot.create(:booking, user_id: reviewer.id, status: "accepted", dates: [1_590_017_200_000, 1_590_019_100_000])
  end

  let(:future_booking) do
    FactoryBot.create(
      :booking,
      user_id: reviewer.id,
      status: "accepted",
      dates: [2_590_000_013_752, 2_590_020_013_752, 2_590_040_013_752, 2_590_060_013_752]
    )
  end

  let(:host_profile) { FactoryBot.create(:host_profile, score: 0) }
  let(:random_booking) { FactoryBot.create(:booking, user_id: host_profile.user.id, status: "accepted") }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  def post_request(req_score, req_body, req_booking)
    post "/api/v1/reviews",
         params: {
           score: req_score,
           body: req_body,
           host_nickname: "Joker",
           user_id: reviewer.id,
           booking_id: req_booking,
           host_profile_id: host_profile.id
         },
         headers: authenticated_headers
  end

  describe "successfully" do
    before do
      post_request(2, "Fantastic host! Fully recommended!", past_booking.id)
      host_profile.reload
    end

    it "with relevant message" do
      expect(json_response["message"]).to eq "Successfully created!"
    end

    it "with 200 status" do
      expect(response.status).to eq 200
    end

    it "updates host profile score" do
      expect(host_profile.score).to eq 2.0
    end

    it "queues a notification email" do
      expect(Delayed::Job.all.count).to eq 1
    end

    it "assigns a notification email at correct queue" do
      expect(Delayed::Job.first.queue).to eq "reviews_email_notifications"
    end

    it "invokes correct method to send notification email" do
      expect(Delayed::Job.first.handler.include?("method_name: :notify_host_create_review")).to eq true
    end
  end

  describe "unsuccessfully" do
    describe "if not all fields are filled in" do
      before { post_request("", "", past_booking.id) }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["Score can't be blank", "Score is not a number", "Body can't be blank"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if body is more than 1000 characters in length" do
      before { post_request(2, "Fantastic host! Fully recommended!" * 100, past_booking.id) }

      it "with relevant error " do
        expect(json_response["errors"]).to eq ["Body is too long (maximum is 1000 characters)"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if user is not associated with the booking" do
      before { post_request(2, "Fantastic host! Fully recommended!", random_booking.id) }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You cannot perform this action!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if associated user tries to review a future booking" do
      before { post_request(2, "Fantastic host! Fully recommended!", future_booking.id) }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You cannot perform this action!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if user is not logged in" do
      before { post "/api/v1/reviews", headers: unauthenticated_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end
  end
end
