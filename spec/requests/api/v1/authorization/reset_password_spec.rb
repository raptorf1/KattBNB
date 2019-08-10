RSpec.describe "Reset Password", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { { HTTP_ACCEPT: "application/json" } }

  describe "POST /api/v1/auth/password" do
    it "sends an email to the user that already exists in the database" do
      post "/api/v1/auth/password", params: { email: user.email,
                                              redirect_url: 'confirmed'
                                           }, headers: headers
      expect(json_response['success']).to eq true
      expect(json_response['message']). to eq "An email has been sent to 'kattbnb@fgreat.com' containing instructions for resetting your password."
      expect(response.status).to eq 200
    end

    it "raises an error if user/email does not exist in the database" do
      post "/api/v1/auth/password", params: { email: 'gameofthrones@mail.ru',
                                              redirect_url: 'confirmed'
                                           }, headers: headers
      expect(json_response['success']).to eq false
      expect(json_response['errors']). to eq ["Unable to find user with email 'gameofthrones@mail.ru'."]
      expect(response.status).to eq 404
    end
  end
end
