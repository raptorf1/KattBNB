RSpec.describe "GET /api/v1/users/:id", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:random_user) { FactoryBot.create(:user) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  def api_call(user_id, token, call_headers)
    get "/api/v1/users/#{user_id}",
        params: {
          id: user_id,
          "access-token": token,
          client: headers["client"]
        },
        headers: call_headers
  end

  describe "succesfully" do
    before { api_call(random_user.id, headers["access-token"], headers) }

    it "responds with correct user id" do
      expect(json_response["id"]).to eq random_user.id
    end

    it "responds with correct user location" do
      expect(json_response["location"]).to eq random_user.location
    end

    it "responds with correct user nickname" do
      expect(json_response["nickname"]).to eq random_user.nickname
    end

    it "responds with correct user avatar" do
      expect(json_response["avatar"]).to eq random_user.avatar
    end

    it "responds with 200 status" do
      expect(response.status).to eq 200
    end
  end

  describe "unsuccessfully" do
    describe "because requested user does not exist in database" do
      before { api_call(1, headers["access-token"], headers) }

      it "with relevant error" do
        expect(json_response["error"]).to eq "User with ID 1 not found"
      end

      it "with 404 status" do
        expect(response.status).to eq 404
      end
    end

    describe "if user is not signed in" do
      before { api_call(user.id, headers["access-token"], unauthenticated_headers) }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end
  end
end
