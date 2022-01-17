RSpec.describe 'PUT /api/v1/auth/password', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }
  let(:user) { FactoryBot.create(:user) }
  let(:auth_token) { user.create_new_auth_token }

  describe 'successfully' do
    before do
      put '/api/v1/auth/password',
          params: {
            current_password: user.password,
            password: '123456',
            password_confirmation: '123456',
            uid: user.uid,
            'access-token': auth_token['access-token'],
            client: auth_token['client']
          },
          headers: headers
      user.reload
    end

    it 'with relevant success message' do
      expect(json_response['success']).to eq true
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'updates password' do
      expect(user.valid_password?('123456')).to eq true
    end
  end

  describe 'unsuccessfully' do
    describe 'if current/old password is incorrect' do
      before do
        put '/api/v1/auth/password',
            params: {
              current_password: 'wrong_password',
              password: '123456',
              password_confirmation: '123456',
              uid: user.uid,
              'access-token': auth_token['access-token'],
              client: auth_token['client']
            },
            headers: headers
      end

      it 'with false success message' do
        expect(json_response['success']).to eq false
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['errors']['full_messages']).to eq ['Current password is invalid']
      end
    end

    describe 'if new password and password confirmation do not match' do
      before do
        put '/api/v1/auth/password',
            params: {
              current_password: user.password,
              password: '123456',
              password_confirmation: 'wrong_password',
              uid: user.uid,
              'access-token': auth_token['access-token'],
              client: auth_token['client']
            },
            headers: headers
      end

      it 'with false success message' do
        expect(json_response['success']).to eq false
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['errors']['full_messages']).to eq ["Password confirmation doesn't match Password"]
      end
    end
  end
end
