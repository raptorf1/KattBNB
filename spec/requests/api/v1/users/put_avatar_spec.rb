RSpec.describe "PUT /api/v1/users/:id", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  def api_call(user_id, call_headers)
    put "/api/v1/users/#{user_id}",
        params: {
          profile_avatar: {
            type: "image/png",
            encoder: "name=carbon (5).png;base64",
            data:
              "iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf",
            extension: "png"
          }
        },
        headers: call_headers
  end

  describe "succesfully" do
    before do
      api_call(user.id, headers)
      user.reload
    end

    it "responds with relevant message" do
      expect(json_response["message"]).to eq "Successfully updated!"
    end

    it "responds with 200 status" do
      expect(response.status).to eq 200
    end

    it "saves the avatar in ActiveStorage" do
      expect(user.profile_avatar.attached?).to eq true
    end
  end

  describe "unsuccessfully" do
    describe "if user is not signed in" do
      before { api_call(user.id, unauthenticated_headers) }

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end

      it "with 401 status" do
        expect(response.status).to eq 401
      end
    end

    describe "if provided user in not found in the database" do
      before { api_call(1, random_user_headers) }

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

    describe "if user tries to update someone else's avatar" do
      before { api_call(user.id, random_user_headers) }

      it "with relevant error" do
        expect(json_response["error"]).to eq ["You cannot perform this action!"]
      end

      it "with 400 status" do
        expect(response.status).to eq 400
      end

      it "with error timestamp" do
        expect(json_response["time"]).to_not eq nil
      end
    end

    describe "if no avatar is supplied in the request" do
      before { put "/api/v1/users/#{user.id}", headers: headers }

      it "with relevant error" do
        expect(json_response["error"]).to eq "No avatar supplied!"
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
