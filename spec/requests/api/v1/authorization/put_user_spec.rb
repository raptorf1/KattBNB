RSpec.describe 'PUT /api/v1/auth', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }
  let(:user) { FactoryBot.create(:user, lang_pref: 'sv-SE', location: 'Tokyo') }
  let(:auth_token) { user.create_new_auth_token }

  describe 'update language preference successfully' do
    before do
      put '/api/v1/auth',
          params: {
            lang_pref: 'en-US',
            uid: user.uid,
            'access-token': auth_token['access-token'],
            client: auth_token['client']
          },
          headers: headers
    end

    it 'with relevant success message' do
      expect(json_response['status']).to eq 'success'
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'is expected to return new language preference' do
      expect(json_response['data']['lang_pref']).to eq 'en-US'
    end
  end

  describe 'update location successfully' do
    before do
      put '/api/v1/auth',
          params: {
            location: 'Japan',
            uid: user.uid,
            'access-token': auth_token['access-token'],
            client: auth_token['client']
          },
          headers: headers
    end

    it 'with relevant success message' do
      expect(json_response['status']).to eq 'success'
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'is expected to return new location' do
      expect(json_response['data']['location']).to eq 'Japan'
    end
  end

  describe 'update message notification successfully' do
    before do
      put '/api/v1/auth',
          params: {
            message_notification: false,
            uid: user.uid,
            'access-token': auth_token['access-token'],
            client: auth_token['client']
          },
          headers: headers
    end

    it 'with relevant success message' do
      expect(json_response['status']).to eq 'success'
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'is expected to return new message notification preference' do
      expect(json_response['data']['message_notification']).to eq false
    end
  end
end
