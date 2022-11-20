RSpec.describe "DELETE /api/v1/auth", type: :request do
  let(:headers) { { HTTP_ACCEPT: "application/json" } }
  let(:user) { FactoryBot.create(:user) }
  let(:auth_token) { user.create_new_auth_token }

  describe "successfully" do
    before do
      delete "/api/v1/auth",
             params: {
               uid: user.uid,
               "access-token": auth_token["access-token"],
               client: auth_token["client"]
             },
             headers: headers
    end

    it "with relevant success message" do
      expect(json_response["status"]).to eq "success"
    end

    it "with 200 status" do
      expect(response.status).to eq 200
    end

    it "deletes user" do
      expect(User.all.length).to eq 0
    end
  end
end
