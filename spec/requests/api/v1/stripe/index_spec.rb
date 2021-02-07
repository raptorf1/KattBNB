RSpec.describe Api::V1::StripeController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let!(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:user2) { FactoryBot.create(:user, email: 'felix@mail.com', nickname: 'MacOS') }
  let!(:profile_user2) { FactoryBot.create(:host_profile, user_id: user2.id, stripe_account_id: 'acct_wTfAyD65545$mf') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/stripe' do
    it 'returns error if user tries to request stripe profile details of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: headers2
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'requires user to be authenticated to request stripe profile details' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'returns a relevant message if no Stripe account is found' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: headers
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'No account'
    end

    it 'returns error if user tries to request stripe dashboard link of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=login_link", headers: headers2
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'requires user to be authenticated to request stripe dashboard link' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=login_link", headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'requires user to be authenticated to create a stripe payment intent' do
      get '/api/v1/stripe?occasion=create_payment_intent', headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'requires user to be authenticated to update a stripe payment intent' do
      get '/api/v1/stripe?occasion=update_payment_intent', headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'requires user to be authenticated to request stripe account deletion' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: not_headers
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'returns error if user tries to request stripe account deletion of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: headers2
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'returns a relevant message if no Stripe account is found when requesting a Stripe account deletion' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: headers
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'No account'
    end

    it 'returns custom generic error if user tries to request stripe account deletion of account that does not exist' do
      get "/api/v1/stripe?host_profile_id=#{profile_user2.id}&occasion=delete_account", headers: headers2
      expect(response.status).to eq 555
      expect(
        json_response['error']
      ).to eq 'There was a problem connecting to our payments infrastructure provider. Please try again later.'
    end
  end
end
