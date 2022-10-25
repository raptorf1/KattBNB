RSpec.describe "GET /api/v1/stripe_actions/retrieve_account_details", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "no stripe account on retrieve details request" do
      before do
        get "/api/v1/stripe_actions/retrieve_account_details?host_profile_id=#{profile_user.id}", headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "No account"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end

    describe "with stripe account on retrieve details request" do
      before do
        profile_user.update(stripe_account_id: "acct_1IWPof2Es2GqkUP2")
        profile_user.reload
        get "/api/v1/stripe_actions/retrieve_account_details?host_profile_id=#{profile_user.id}", headers: headers
      end

      it "with correct number of keys in the response" do
        expect(json_response.count).to eq 2
      end

      it "with correct keys in the response" do
        expect(json_response).to include("payouts_enabled", "requirements")
      end

      it "with 203 status" do
        expect(response.status).to eq 203
      end
    end
  end

  describe "unsuccesfully" do
    describe "when stripe servers report an error on retrieve details request" do
      before do
        profile_user.update(stripe_account_id: "acct_1IWPocff2jhEsk2jGiqkrtUd5P72")
        profile_user.reload
        get "/api/v1/stripe_actions/retrieve_account_details?host_profile_id=#{profile_user.id}", headers: headers
      end

      it "with relevant error" do
        expect(
          json_response["error"]
        ).to eq "There was a problem connecting to our payments infrastructure provider. Please try again later."
      end

      it "with 555 status" do
        expect(response.status).to eq 555
      end
    end

    describe "for request of stripe account details of another user" do
      before do
        get "/api/v1/stripe_actions/retrieve_account_details?host_profile_id=#{profile_user.id}",
            headers: random_user_headers
      end

      it "with relevant error" do
        expect(json_response["error"]).to eq "You cannot perform this action!"
      end

      it "with 422 status" do
        expect(response.status).to eq 422
      end
    end

    describe "if not authenticated and requests own stripe account details" do
      before do
        get "/api/v1/stripe_actions/retrieve_account_details?host_profile_id=#{profile_user.id}",
            headers: unauthenticated_headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end
  end
end
