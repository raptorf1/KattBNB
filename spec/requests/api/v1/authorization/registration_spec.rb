RSpec.describe 'POST /api/v1/auth', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    before do
      post '/api/v1/auth',
           params: {
             email: 'zane@craft.se',
             password: 'password',
             password_confirmation: 'password',
             nickname: 'KittenPrincess',
             location: 'Gothenburg',
             confirm_success_url: 'confirmed',
             lang_pref: 'sv-SE'
           },
           headers: headers
    end

    it 'with relevant success message' do
      expect(json_response['status']).to eq 'success'
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end
  end

  describe 'unsuccessfully' do
    describe 'with a non-matching password confirmation' do
      before do
        post '/api/v1/auth',
             params: {
               email: 'zane@craft.se',
               password: 'password',
               password_confirmation: 'bad_password',
               nickname: 'KittenPrincess',
               location: 'Gothenburg',
               confirm_success_url: 'confirmed',
               lang_pref: 'sv-SE'
             },
             headers: headers
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['errors']['password_confirmation']).to eq ["doesn't match Password"]
      end
    end

    describe 'with an invalid email address' do
      before do
        post '/api/v1/auth',
             params: {
               email: 'george@craft',
               password: 'password',
               password_confirmation: 'password',
               nickname: 'raptorf1',
               location: 'Stockholm',
               confirm_success_url: 'confirmed',
               lang_pref: 'sv-SE'
             },
             headers: headers
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['errors']['email']).to eq ['is invalid']
      end
    end

    describe 'with an already registered email address' do
      before do
        FactoryBot.create(:user, email: 'carla@craft.se')
        post '/api/v1/auth',
             params: {
               email: 'carla@craft.se',
               password: 'password',
               password_confirmation: 'password',
               nickname: 'MergerOfConflicts',
               location: 'Stockholm',
               confirm_success_url: 'confirmed',
               lang_pref: 'sv-SE'
             },
             headers: headers
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['errors']['email']).to eq ['has already been taken']
      end
    end

    describe 'with an already registered username' do
      before do
        FactoryBot.create(:user, nickname: 'KattenFelix')
        post '/api/v1/auth',
             params: {
               email: 'pontus@craft.se',
               password: 'password',
               password_confirmation: 'password',
               nickname: 'KattenFelix',
               location: 'Stockholm',
               confirm_success_url: 'confirmed',
               lang_pref: 'sv-SE'
             },
             headers: headers
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['errors']['nickname']).to eq ['has already been taken']
      end
    end
  end
end
