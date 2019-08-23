RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:user2) { FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten') }
  let(:host_profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:host_profile_user2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user2_credentials) { user2.create_new_auth_token }
  let(:user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials) }
  let(:user2_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user2_credentials) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'DELETE /api/v1/host_profiles/id' do

    it 'deletes the host profile of the associated user' do
      delete "/api/v1/host_profiles/#{host_profile_user.id}", headers: user_headers
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully deleted your host profile'
    end

    it 'does not delete host profile associated with another user' do
      delete "/api/v1/host_profiles/#{host_profile_user2.id}", headers: user_headers
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action'
    end

    it 'does not delete any host profile if user is not authenticated' do
      delete "/api/v1/host_profiles/#{host_profile_user.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
