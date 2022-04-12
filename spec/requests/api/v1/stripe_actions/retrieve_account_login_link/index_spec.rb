RSpec.describe 'GET /api/v1/stripe_actions/retrieve_account_login_link', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id, stripe_account_id: 'acct_1IWPof2Es2GqkUP2') }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:random_user) { FactoryBot.create(:user) }
  let(:random_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(random_credentials) }

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    describe 'if stripe account is valid on requesting a stripe dashboard link' do
      before do
        get "/api/v1/stripe_actions/retrieve_account_login_link?host_profile_id=#{profile_user.id}", headers: headers
      end

      it 'with URL in the response' do
        expect(json_response['url']).to include('https://connect.stripe.com/express/')
      end

      it 'with 200 status' do
        expect(response.status).to eq 200
      end
    end
  end

  describe 'unsuccesfully' do
    describe 'if stripe servers report an error on requesting a stripe dashboard link' do
      before do
        profile_user.update(stripe_account_id: 'acct_1IfgWPofgh2Es52GqkUgffP2')
        profile_user.reload
        get "/api/v1/stripe_actions/retrieve_account_login_link?host_profile_id=#{profile_user.id}", headers: headers
      end

      it 'with relevant error' do
        expect(
          json_response['error']
        ).to eq 'There was a problem connecting to our payments infrastructure provider. Please try again later.'
      end

      it 'with 555 status' do
        expect(response.status).to eq 555
      end
    end

    describe 'if user tries to request stripe dashboard link of another user' do
      before do
        get "/api/v1/stripe_actions/retrieve_account_login_link?host_profile_id=#{profile_user.id}",
            headers: random_user_headers
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end
    end

    describe 'if user is not authenticated and requests stripe dashboard link' do
      before do
        get "/api/v1/stripe_actions/retrieve_account_login_link?host_profile_id=#{profile_user.id}",
            headers: unauthenticated_headers
      end

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'with 401 status' do
        expect(response.status).to eq 401
      end
    end
  end
end
