RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe "Sessions", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { { HTTP_ACCEPT: "application/json" } }

  describe "POST /api/v1/auth/sign_in" do
    it "valid credentials returns a user" do
      post "/api/v1/auth/sign_in", params: { email: user.email,
                                             password: user.password
                                          }, headers: headers

      expected_response = {
        "data" => {
          "id" => user.id, "uid" => user.email, "email" => user.email,
          "provider" => "email", "name" => nil, "nickname" => user.nickname,
          "location" => user.location, "image" => nil, "avatar" => nil, "allow_password_change" => false,
          "message_notification" => true, "lang_pref" => nil
        }
      }

      expect(json_response).to eq expected_response
    end

    it "returns a user in under 1 ms and with iteration rate of 5000000 per second" do
      post_request = post "/api/v1/auth/sign_in", params: { email: user.email,
                                                 password: user.password
                                              }, headers: headers
      expect { post_request }.to perform_under(1).ms.sample(20).times
      expect { post_request }.to perform_at_least(5000000).ips
    end

    it "does not allow user to sign in unless he clicks on the activation link sent by email from the API" do
      user2 = User.create(email: 'alonso@formula1.com', password: 'password', password_confirmation: 'password', location: 'Athens', nickname: 'boa')
      post "/api/v1/auth/sign_in", params: { email: user2.email,
                                             password: user2.password
                                          }, headers: headers
      expect(response.status).to eq 401
      expect(json_response['success']).to eq false
      expect(json_response['errors']).to eq ["A confirmation email was sent to your account at alonso@formula1.com. You must follow the instructions in the email before your account can be activated."]
    end

    it "invalid password returns an error message" do
      post "/api/v1/auth/sign_in", params: { email: user.email,
                                             password: "bad_password"
                                          }, headers: headers

      expect(json_response["errors"])
        .to eq ["Invalid login credentials. Please try again."]

      expect(response.status).to eq 401
    end

    it "invalid email returns an error message" do
      post "/api/v1/auth/sign_in", params: { email: "bad@craft.com",
                                             password: user.password
                                          }, headers: headers

      expect(json_response["errors"])
        .to eq ["Invalid login credentials. Please try again."]

      expect(response.status).to eq 401
    end
  end
end
