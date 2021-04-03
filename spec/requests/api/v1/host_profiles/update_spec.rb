RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:user2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:host_profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:host_profile_user2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let(:credentials_user) { user.create_new_auth_token }
  let(:credentials_user2) { user2.create_new_auth_token }
  let(:headers_user) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user) }
  let(:headers_user2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user2) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'PATCH /api/v1/host_profiles/id' do
    it "updates fields of associated user's host profile according to params" do
      patch "/api/v1/host_profiles/#{host_profile_user.id}",
            params: {
              description: 'I am the best cat sitter in the whole wide world!!!',
              price_per_day_1_cat: '250'
            },
            headers: headers_user
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully updated your host profile!'
      host_profile_user.reload
      expect(host_profile_user.description).to eq 'I am the best cat sitter in the whole wide world!!!'
    end

    it 'updates fields in under 1 ms and with iteration rate of at least 3000000 per second' do
      update_request =
        patch "/api/v1/host_profiles/#{host_profile_user.id}",
              params: {
                description: 'I am the best cat sitter in the whole wide world!!!',
                price_per_day_1_cat: '250'
              },
              headers: headers_user
      expect { update_request }.to perform_under(1).ms.sample(20).times
      expect { update_request }.to perform_at_least(3_000_000).ips
    end

    it "does not update another user's host profile" do
      patch "/api/v1/host_profiles/#{host_profile_user2.id}",
            params: {
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
      put "/api/v1/host_profiles/#{host_profile_user.id}",
          params: {
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

    it 'updates fields in under 1 ms and with iteration rate of at least 2000000 per second' do
      update_request =
        put "/api/v1/host_profiles/#{host_profile_user.id}",
            params: {
              description: 'I am the best cat sitter in the whole wide world!!!',
              full_address: 'Charles de Gaulle Airport, Paris, France',
              price_per_day_1_cat: '250',
              supplement_price_per_cat_per_day: '150',
              max_cats_accepted: '5'
            },
            headers: headers_user
      expect { update_request }.to perform_under(1).ms.sample(20).times
      expect { update_request }.to perform_at_least(2_000_000).ips
    end

    it "does not update another user's host profile" do
      put "/api/v1/host_profiles/#{host_profile_user2.id}",
          params: {
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
