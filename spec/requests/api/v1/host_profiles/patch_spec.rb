RSpec.describe 'PATCH /api/v1/host_profiles/id', type: :request do
  let(:host_profile) { FactoryBot.create(:host_profile) }
  let(:host_credentials) { host_profile.user.create_new_auth_token }
  let(:host_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(host_credentials) }

  let(:random_host_profile) { FactoryBot.create(:host_profile) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

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
    before { patch_request(host_profile.id, host_headers) }

    it "with 200 status for associated user's host profile" do
      expect(response.status).to eq 200
    end

    it "with relevant message for associated user's host profile" do
      expect(json_response['message']).to eq 'You have successfully updated your host profile!'
    end
  end

  describe 'unsuccessfully' do
    describe "when updating another user's host profile" do
      before { patch_request(random_host_profile.id, host_headers) }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end
    end

    describe 'if not authenticated' do
      before { patch_request(host_profile.id, unauthenticated_headers) }

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'with 401 status' do
        expect(response.status).to eq 401
      end
    end
  end
end
