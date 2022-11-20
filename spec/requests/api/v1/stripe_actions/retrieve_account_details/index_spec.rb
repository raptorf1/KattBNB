RSpec.describe "GET /api/v1/stripe_actions/retrieve_account_details", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let!(:credentials) { user.create_new_auth_token }
  let!(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let!(:random_user) { FactoryBot.create(:user) }
  let!(:random_credentials) { random_user.create_new_auth_token }
  let!(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_credentials) }

  let!(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "no stripe account on retrieve details request" do
      before { get "/api/v1/stripe_actions/retrieve_account_details", headers: headers }

      it "with relevant message" do
        expect(json_response["message"]).to eq "Host has no Stripe account configured! Nothing to perform."
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end

    describe "with stripe account on retrieve details request" do
      before do
        profile_user.update(stripe_account_id: "acct_1IWPof2Es2GqkUP2")
        profile_user.reload
        get "/api/v1/stripe_actions/retrieve_account_details", headers: headers
      end

      it "with correct number of keys in the response" do
        expect(json_response.count).to eq 2
      end

      it "with correct keys in the response" do
        expect(json_response).to include("payouts_enabled", "requirements")
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end
  end

  describe "unsuccesfully" do
    describe "if not authenticated" do
      before { get "/api/v1/stripe_actions/retrieve_account_details", headers: unauthenticated_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "when stripe servers report an error" do
      before do
        profile_user.update(stripe_account_id: "acct_1IWPocff2jhEsk2jGiqkrtUd5P72")
        profile_user.reload
        get "/api/v1/stripe_actions/retrieve_account_details", headers: headers
      end

      it "with relevant error" do
        expect(json_response["errors"][0]).to match("or that account does not exist")
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "when user has no host profile" do
      before { get "/api/v1/stripe_actions/retrieve_account_details", headers: random_user_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["User has no host profile!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end
  end
end
