RSpec.describe "GET /api/v1/stripe_actions/delete_account", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let!(:credentials) { user.create_new_auth_token }
  let!(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let!(:random_user) { FactoryBot.create(:user) }
  let!(:random_profile_user) do
    FactoryBot.create(:host_profile, user_id: random_user.id, stripe_account_id: "incorrect_id")
  end
  let!(:random_credentials) { random_user.create_new_auth_token }
  let!(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_credentials) }

  let!(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  Stripe.api_key = StripeService.get_api_key

  describe "successfully" do
    describe "with valid stripe account on delete request" do
      before do
        created_account =
          Stripe::Account.create(
            {
              type: "custom",
              country: "US",
              email: "jenny.rosen@example.com",
              capabilities: {
                card_payments: {
                  requested: true
                },
                transfers: {
                  requested: true
                }
              }
            }
          )
        profile_user.update(stripe_account_id: created_account.id)
        get "/api/v1/stripe_actions/delete_account", headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end

    describe "no stripe account on delete request" do
      before { get "/api/v1/stripe_actions/delete_account", headers: headers }

      it "with relevant message" do
        expect(json_response["message"]).to eq "Host has no Stripe account configured! Nothing to perform."
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end
  end

  describe "unsuccesfully" do
    describe "if user is not not authenticated and requests stripe account deletion" do
      before { get "/api/v1/stripe_actions/delete_account", headers: unauthenticated_headers }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "if user has no host profile" do
      before do
        profile_user.destroy
        get "/api/v1/stripe_actions/delete_account", headers: headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["User has no host profile!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end

    describe "if user tries to request stripe account deletion of account that does not exist (stripe server error)" do
      before { get "/api/v1/stripe_actions/delete_account", headers: random_user_headers }

      it "with relevant error" do
        expect(json_response["errors"][0]).to match("or that account does not exist")
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end
    end
  end
end
