RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:user2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:host_profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:host_profile_user2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let!(:booking1) { FactoryBot.create(:booking, host_nickname: user.nickname, status: 'pending', user_id: user2.id, dates: [125, 1562889600000, 1562976000000]) }
  let!(:booking2) { FactoryBot.create(:booking, host_nickname: user2.nickname, status: 'canceled', user_id: user.id, dates: [125, 1562889600000, 1562976000000]) }
  let!(:booking3) { FactoryBot.create(:booking, host_nickname: user2.nickname, status: 'pending', user_id: user.id, dates: [1562889600000, 1562976000000]) }
  let(:credentials_user) { user.create_new_auth_token }
  let(:credentials_user2) { user2.create_new_auth_token }
  let(:headers_user) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user) }
  let(:headers_user2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user2) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'PATCH /api/v1/host_profiles/id' do

    it "updates fields of associated user's host profile according to params" do
      patch "/api/v1/host_profiles/#{host_profile_user.id}", params: {
        description: 'I am the best cat sitter in the whole wide world!!!',
        price_per_day_1_cat: '250'
      },
      headers: headers_user
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully updated your host profile!'
      host_profile_user.reload
      expect(host_profile_user.description).to eq 'I am the best cat sitter in the whole wide world!!!'
    end

    it "does not update another user's host profile" do
      patch "/api/v1/host_profiles/#{host_profile_user2.id}", params: {
        full_address: 'Charles de Gaulle Airport, Paris, France',
        price_per_day_1_cat: '250'
      }, 
      headers: headers_user
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'does not update any host profile if user is not authenticated' do
      patch "/api/v1/host_profiles/#{host_profile_user.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end

  describe 'PUT /api/v1/host_profiles/id' do

    it "updates all fields of associated user's host profile according to params" do
      put "/api/v1/host_profiles/#{host_profile_user.id}", params: {
        description: 'I am the best cat sitter in the whole wide world!!!',
        full_address: 'Charles de Gaulle Airport, Paris, France',
        price_per_day_1_cat: '250',
        supplement_price_per_cat_per_day: '150',
        max_cats_accepted: '5'
      },
      headers: headers_user
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully updated your host profile!'
      host_profile_user.reload
      expect(host_profile_user.price_per_day_1_cat).to eq 250
      expect(host_profile_user.max_cats_accepted).to eq 5
    end

    it 'raises error if pending booking exists' do
      put "/api/v1/host_profiles/#{host_profile_user.id}", params: {
        availability: [125, 126, 127, 128]
      },
      headers: headers_user
      expect(response.status).to eq 422
      expect(json_response['error']).to eq ['Cannot update availability. You have incoming bookings to some of those dates! Refresh the page or visit you bookings dashboard.']
    end

    it 'does not raise error if pending booking does not exist' do
      put "/api/v1/host_profiles/#{host_profile_user2.id}", params: {
        availability: [125, 126, 127, 128]
      },
      headers: headers_user2
      expect(response.status).to eq 200
    end

    it 'does not raise error if pending booking exists but dates do not match' do
      put "/api/v1/host_profiles/#{host_profile_user2.id}", params: {
        availability: [125, 126, 127, 128]
      },
      headers: headers_user2
      expect(response.status).to eq 200
    end

    it "does not update another user's host profile" do
      put "/api/v1/host_profiles/#{host_profile_user2.id}", params: {
        description: 'I am the best cat sitter in the whole wide world!!!',
        full_address: 'Charles de Gaulle Airport, Paris, France',
        price_per_day_1_cat: '250',
        supplement_price_per_cat_per_day: '150',
        max_cats_accepted: '5'
      }, 
      headers: headers_user
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'does not update any host profile if user is not authenticated' do
      put "/api/v1/host_profiles/#{host_profile_user.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
