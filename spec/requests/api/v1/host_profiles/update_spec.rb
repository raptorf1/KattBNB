RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:user2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:host_profile_user) { FactoryBot.create(:host_profile) }
  let(:host_profile_user2) { FactoryBot.create(:host_profile) }
  let(:credentials_user) { user.create_new_auth_token }
  let(:credentials_user2) { user2.create_new_auth_token }
  let(:headers_user) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user) }
  let(:headers_user2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user2) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'PATCH /api/v1/host_profiles/id' do

    it "updates fields of associated user's host profile according to params" do
      patch "/api/v1/host_profiles/#{host_profile_user.id}", params: {
        description: 'I am the best cat sitter in the whole wide world!!!',
        availability: '[125, 126, 127, 128]'
      },
      headers: headers_user
   #   host_profile.reload
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'Profile successfully updated'
    end

    it "does not update another user's host profile" do
      patch "/api/v1/host_profiles/#{host_profile_user2.id}", params: {
        full_address: 'Charles de Gaulle Airport, Paris, France',
        price_per_day_1_cat: '250'
      }, 
      headers: headers_user
#      host_profile.reload
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action'
    end

    it 'does not update any host profile if user is not authenticated' do
      patch "/api/v1/host_profiles/#{host_profile_user.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
