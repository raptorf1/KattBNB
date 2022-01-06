RSpec.describe 'POST /api/v1/auth/password', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    before { post '/api/v1/auth/password', params: { email: user.email, redirect_url: 'confirmed' }, headers: headers }

    it 'is expected to return a success message' do
      expect(json_response['success']).to eq true
    end

    it 'is expected to return a 200 response status' do
      expect(response.status).to eq 200
    end

    it 'is expected to return message about confirmation email' do
      expect(
        json_response['message']
      ).to eq 'An email has been sent to kattbnb@fgreat.com containing instructions for resetting your password.'
    end
  end

  describe 'unsuccessfully if user/email does not exist in the database' do
    before do
      post '/api/v1/auth/password',
           params: {
             email: 'gameofthrones@mail.ru',
             redirect_url: 'confirmed'
           },
           headers: headers
    end

    it 'is expected to return a 404 response status' do
      expect(response.status).to eq 404
    end

    it 'is expected to return an error message' do
      expect(json_response['errors']).to eq ['Unable to find user with email gameofthrones@mail.ru.']
    end

    it 'is expected to return a false success message' do
      expect(json_response['success']).to eq false
    end
  end
end
