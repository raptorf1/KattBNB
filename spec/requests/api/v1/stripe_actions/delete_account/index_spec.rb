RSpec.describe "GET /api/v1/stripe_actions/delete_account", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_profile_user) do
    FactoryBot.create(:host_profile, user_id: random_user.id, stripe_account_id: "incorrect_id")
  end
  let(:random_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "no stripe account on delete request" do
      before { get "/api/v1/stripe_actions/delete_account?host_profile_id=#{profile_user.id}", headers: headers }

      it "with relevant message" do
        expect(json_response["message"]).to eq "No account"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end
    end
  end

  describe "unsuccesfully" do
    describe "if user is not not authenticated and requests stripe account deletion" do
      before do
        get "/api/v1/stripe_actions/delete_account?host_profile_id=#{profile_user.id}", headers: unauthenticated_headers
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "if user tries to request stripe account deletion of another user" do
      before do
        get "/api/v1/stripe_actions/delete_account?host_profile_id=#{profile_user.id}", headers: random_user_headers
      end

      it "with relevant error" do
        expect(json_response["error"]).to eq "You cannot perform this action!"
      end

      it "with 422 status" do
        expect(response.status).to eq 422
      end
    end

    describe "if user tries to request stripe account deletion of account that does not exist" do
      before do
        get "/api/v1/stripe_actions/delete_account?host_profile_id=#{random_profile_user.id}",
            headers: random_user_headers
      end

      it "with relevant custom error" do
        expect(
          json_response["error"]
        ).to eq "There was a problem connecting to our payments infrastructure provider. Please try again later."
      end

      it "with 555 custom status" do
        expect(response.status).to eq 555
      end
    end
  end
end
