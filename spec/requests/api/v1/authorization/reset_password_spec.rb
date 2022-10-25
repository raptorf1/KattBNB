RSpec.describe "POST /api/v1/auth/password", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    before { post "/api/v1/auth/password", params: { email: user.email, redirect_url: "confirmed" }, headers: headers }

    it "with relevant success message" do
      expect(json_response["success"]).to eq true
    end

    it "with 200 status" do
      expect(response.status).to eq 200
    end

    it "with relevant message about confirmation email" do
      expect(
        json_response["message"]
      ).to eq "An email has been sent to #{user.email} containing instructions for resetting your password."
    end
  end

  describe "unsuccessfully if user/email does not exist in the database" do
    before do
      post "/api/v1/auth/password",
           params: {
             email: "gameofthrones@mail.ru",
             redirect_url: "confirmed"
           },
           headers: headers
    end

    it "with 404 status" do
      expect(response.status).to eq 404
    end

    it "with relevant error" do
      expect(json_response["errors"]).to eq ["Unable to find user with email gameofthrones@mail.ru."]
    end

    it "with false success message" do
      expect(json_response["success"]).to eq false
    end
  end
end
