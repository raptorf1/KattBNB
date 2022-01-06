RSpec.describe 'POST /api/v1/auth/sign_in', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    before { post '/api/v1/auth/sign_in', params: { email: user.email, password: user.password }, headers: headers }

    it 'is expected to return a 200 response status' do
      expect(response.status).to eq 200
    end
  end

  describe 'unsuccessfully' do
    describe 'if they have not confirmed their email' do
      before do
        unconfirmed_user = FactoryBot.create(:user, confirmed_at: nil)

        post '/api/v1/auth/sign_in',
             params: {
               email: unconfirmed_user.email,
               password: unconfirmed_user.password
             },
             headers: headers
      end

      it 'is expected to return a 401 response status' do
        expect(response.status).to eq 401
      end

      it 'is expected to return an error message' do
        expect(json_response['errors']).to eq [
             'A confirmation email was sent to your account at kattbnb@fgreat.com. You must follow the instructions in the email before your account can be activated.'
           ]
      end

      it 'is expected to return a false success message' do
        expect(json_response['success']).to eq false
      end
    end

    describe 'with invalid credentials' do
      before do
        post '/api/v1/auth/sign_in', params: { email: 'wrong@email.com', password: 'bad_password' }, headers: headers
      end

      it 'is expected to return a 401 response status' do
        expect(response.status).to eq 401
      end

      it 'is expected to return an error message' do
        expect(json_response['errors']).to eq ['Invalid login credentials. Please try again.']
      end

      it 'is expected to return a false success message' do
        expect(json_response['success']).to eq false
      end
    end
  end
end
