RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:not_headers) { {HTTP_ACCEPT: 'application/json'} }
    
    describe 'GET /api/v1/host_profiles/id' do
      before do
        post '/api/v1/host_profiles', params: {
          description: 'Hello, I am the best, better than the rest!',
          full_address: 'Solvarvsgatan 32, 41508, Göteborg, Sweden',
          price_per_day_1_cat: '100',
          supplement_price_per_cat_per_day: '35',
          max_cats_accepted: '3',
          availability: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
          lat: '57.746517',
          long: '12.028278',
          latitude: '57.746517',
          longitude: '12.028278',
          user_id: user.id
        },
        headers: headers
        get "/api/v1/host_profiles/#{HostProfile.last.id}", headers: headers
      end

      it 'returns a success response' do
        expect(response.status).to eq 200
      end

      it 'returns a specific host profile' do
        profile = HostProfile.last
        expect(json_response['id']).to eq profile.id
      end

      it 'has correct keys in the response' do
        expect(json_response).to include('id')
        expect(json_response).to include('description')
        expect(json_response).to include('price_per_day_1_cat')
        expect(json_response).to include('supplement_price_per_cat_per_day')
        expect(json_response).to include('max_cats_accepted')
        expect(json_response).to include('availability')
        expect(json_response).to include('full_address')
        expect(json_response).to include('user')
        expect(json_response.count).to eq 8
        end
      end

      describe 'GET /api/v1/host_profiles/id' do
        it 'requires user to be authenticated to see individual host profile' do
          post '/api/v1/host_profiles', params: {
            description: 'Hello, I am the best, better than the rest!',
            full_address: 'Solvarvsgatan 32, 41508, Göteborg, Sweden',
            price_per_day_1_cat: '100',
            supplement_price_per_cat_per_day: '35',
            max_cats_accepted: '3',
            availability: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
            lat: '57.746517',
            long: '12.028278',
            latitude: '57.746517',
            longitude: '12.028278',
            user_id: user.id
          },
          headers: headers
          get "/api/v1/host_profiles/#{HostProfile.last.id}", headers: not_headers
          expect(response.status).to eq 401
          expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
        end
      end
    end
