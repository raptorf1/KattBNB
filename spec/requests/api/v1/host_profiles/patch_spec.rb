RSpec.describe 'PATCH /api/v1/host_profiles/id', type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:credentials_user) { user.create_new_auth_token }
  let(:headers_user) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user) }
  let(:host_profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }

  let(:user2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:credentials_user2) { user2.create_new_auth_token }
  let(:headers_user2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user2) }
  let(:host_profile_user2) { FactoryBot.create(:host_profile, user_id: user2.id) }

  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  def patch_request(id, headers)
    patch "/api/v1/host_profiles/#{id}",
          params: {
            description: 'I am the best cat sitter in the whole wide world!!!',
            full_address: 'Charles de Gaulle Airport, Paris, France',
            price_per_day_1_cat: '250',
            supplement_price_per_cat_per_day: '150',
            max_cats_accepted: '5'
          },
          headers: headers
  end

  describe 'succesfully' do
    before do
      patch_request(host_profile_user.id, headers_user)
      host_profile_user.reload
    end

    it "with 200 status for associated user's host profile" do
      expect(response.status).to eq 200
    end

    it "with relevant message for associated user's host profile" do
      expect(json_response['message']).to eq 'You have successfully updated your host profile!'
    end
  end

  describe 'unsuccessfully' do
    describe "when updating another user's host profile" do
      before { patch_request(host_profile_user2.id, headers_user) }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end
    end

    describe 'if not authenticated' do
      before { patch_request(host_profile_user.id, headers_no_auth) }

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'with 401 status' do
        expect(response.status).to eq 401
      end
    end
  end
end
