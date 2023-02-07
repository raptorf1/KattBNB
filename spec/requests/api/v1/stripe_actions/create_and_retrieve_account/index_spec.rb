RSpec.describe "GET /api/v1/stripe_actions/create_and_retrieve_account", type: :request do
  let!(:profile_user) { FactoryBot.create(:host_profile) }
  let!(:credentials) { profile_user.user.create_new_auth_token }
  let!(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let!(:random_user) { FactoryBot.create(:user) }
  let!(:random_credentials) { random_user.create_new_auth_token }
  let!(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_credentials) }

  let!(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "unsuccesfully" do
    describe "if not authenticated" do
      before { get "/api/v1/stripe_actions/create_and_retrieve_account", headers: unauthenticated_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "when user has no host profile" do
      before { get "/api/v1/stripe_actions/create_and_retrieve_account", headers: random_user_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["User has no host profile!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "when stripe servers report an error" do
      before do
        get "/api/v1/stripe_actions/create_and_retrieve_account?code=kdjfshdf87f8gjh87f", headers: headers
        profile_user.reload
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq(
          [
            "There was a problem creating your account with our payments infrastructure provider. Please try again later."
          ]
        )
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end

      it "with host profile's stripe account id not updated" do
        expect(profile_user.stripe_account_id).to eq nil
      end
    end
  end
end
