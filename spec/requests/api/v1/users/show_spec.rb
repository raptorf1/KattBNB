RSpec.describe "GET /api/v1/users/:id", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:random_user) { FactoryBot.create(:user) }

  let(:headers) { { HTTP_ACCEPT: "application/json" } }

  def api_call(user_id, call_headers)
    get "/api/v1/users/#{user_id}", params: { id: user_id }, headers: call_headers
  end

  describe "succesfully" do
    before { api_call(random_user.id, headers) }

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
      before { api_call(1, headers) }

      it "with relevant error" do
        expect(json_response["error"]).to eq "User with ID 1 not found!"
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end

      it "with error timestamp" do
        expect(json_response["time"]).to_not eq nil
      end
    end
  end
end
