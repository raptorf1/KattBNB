RSpec.describe "GET /api/v1/stripe_actions/retrieve_account_login_link", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id, stripe_account_id: "acct_1IWPof2Es2GqkUP2") }
  let!(:credentials) { user.create_new_auth_token }
  let!(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let!(:random_user) { FactoryBot.create(:user) }
  let!(:random_credentials) { random_user.create_new_auth_token }
  let!(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_credentials) }

  let!(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "if stripe account exists on requesting a stripe dashboard link" do
      before { get "/api/v1/stripe_actions/retrieve_account_login_link", headers: headers }

      it "with URL in the response" do
        expect(json_response["url"]).to include("https://connect.stripe.com/express/")
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end

    describe "if stripe account does not exist on requesting a stripe dashboard link" do
      before do
        profile_user.update(stripe_account_id: nil)
        get "/api/v1/stripe_actions/retrieve_account_login_link", headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Host has no Stripe account configured! Nothing to perform."
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end
  end

  describe "unsuccesfully" do
    describe "if user is not authenticated" do
      before { get "/api/v1/stripe_actions/retrieve_account_login_link", headers: unauthenticated_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "if stripe servers report an error" do
      before do
        profile_user.update(stripe_account_id: "acct_1IfgWPofgh2Es52GqkUgffP2")
        get "/api/v1/stripe_actions/retrieve_account_login_link", headers: headers
      end

      it "with relevant error" do
        expect(json_response["errors"][0]).to match("or that account does not exist")
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if user has no host profile" do
      before { get "/api/v1/stripe_actions/retrieve_account_login_link", headers: random_user_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["User has no host profile!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end
  end
end
