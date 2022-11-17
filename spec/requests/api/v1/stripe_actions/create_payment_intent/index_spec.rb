RSpec.describe "GET /api/v1/stripe_actions/create_payment_intent", type: :request do
  let(:user) { FactoryBot.create(:user, email: "george@mail.com", nickname: "Alonso") }
  let!(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "succesfully" do
    describe "when api and client amounts are correct" do
      before do
        get "/api/v1/stripe_actions/create_payment_intent?inDate=1587945600000&outDate=1588204800000&cats=2&host=#{user.nickname}&amount=733",
            headers: headers
      end

      it "with intent id in the response" do
        expect(json_response["intent_id"]).to include("pi", "secret")
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end
  end

  describe "unsuccesfully" do
    describe "when stripe servers report an error on creating a payment intent" do
      before do
        get "/api/v1/stripe_actions/create_payment_intent?inDate=1587945600000&outDate=1588204800000&cats=2&host=#{user.nickname}&amount=733&currency=jdhf",
            headers: headers
      end

      it "with relevant error" do
        expect(json_response["errors"][0]).to match "Invalid currency: jdhf."
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "when api and client amounts do not match" do
      before do
        get "/api/v1/stripe_actions/create_payment_intent?inDate=1587945600000&outDate=1588204800000&cats=2&host=#{user.nickname}&amount=1733",
            headers: headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq [
             "An error occured calculating the booking amount! Please try again and if the problem persists, contact our support."
           ]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if user is not authenticated and tries to create a stripe payment intent" do
      before { get "/api/v1/stripe_actions/create_payment_intent", headers: unauthenticated_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end
  end
end
