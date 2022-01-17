RSpec.describe 'PUT /api/v1/users', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:user2) { FactoryBot.create(:user, email: 'a@a.com', nickname: 'Rails is king!') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  def api_call(user_id, token, call_headers)
    put "/api/v1/users/#{user_id}",
        params: {
          profile_avatar: {
            type: 'image/png',
            encoder: 'name=carbon (5).png;base64',
            data:
              'iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf',
            extension: 'png'
          },
          'access-token': token,
          client: headers['client']
        },
        headers: call_headers
  end

  it 'avatar is not present before tha api call' do
    expect(user.profile_avatar.attached?).to eq false
  end

  describe 'succesfully' do
    before do
      api_call(user.id, headers['access-token'], headers)
      user.reload
    end

    it 'responds with relevant message' do
      expect(json_response['message']).to eq 'Successfully updated!'
    end

    it 'responds with 200 status' do
      expect(response.status).to eq 200
    end

    it 'saves the avatar in ActiveStorage' do
      expect(user.profile_avatar.attached?).to eq true
    end
  end

  describe 'unsuccessfully' do
    describe 'cause token/client expired or are invalid' do
      before { api_call(user.id, 'kjhfvHTghjjhjbjk', headers) }

      it 'with relevant error' do
        expect(json_response['error']).to eq ['You cannot perform this action!']
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end
    end

    it 'with relevant error if user is not signed in' do
      api_call(user.id, headers['access-token'], not_headers)
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    describe "if user tries to update someone else's avatar" do
      before { api_call(user.id, headers['access-token'], headers2) }

      it 'with relevant error' do
        expect(json_response['error']).to eq ['You cannot perform this action!']
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end
    end
  end
end
