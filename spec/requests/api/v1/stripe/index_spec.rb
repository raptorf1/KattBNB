RSpec.describe 'GET /api/v1/stripe', type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:profile_user) { FactoryBot.create(:host_profile, user_id: user.id) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:user2) { FactoryBot.create(:user, email: 'felix@mail.com', nickname: 'MacOS') }
  let(:profile_user2) { FactoryBot.create(:host_profile, user_id: user2.id, stripe_account_id: 'acct_wTfAyD65545$mf') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'successfully' do
    it 'with relevant message if no Stripe account is found' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: headers
      expect(json_response['message']).to eq 'No account'
    end

    it 'with 200 status if no Stripe account is found' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: headers
      expect(response.status).to eq 200
    end

    it 'with relevant message if no Stripe account is found when requesting a Stripe account deletion' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: headers
      expect(json_response['message']).to eq 'No account'
    end

    it 'with 200 status if no Stripe account is found when requesting a Stripe account deletion' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: headers
      expect(response.status).to eq 200
    end
  end

  describe 'unsuccesfully' do
    it 'with relevant error if user tries to request stripe profile details of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: headers2
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'with 422 status if user tries to request stripe profile details of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: headers2
      expect(response.status).to eq 422
    end

    it 'with relevant error if user is not authenticated and tries to request own stripe profile details' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'with 401 status if user is not authenticated and tries to request own stripe profile details' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=retrieve", headers: not_headers
      expect(response.status).to eq 401
    end

    it 'with relevant error if user tries to request stripe dashboard link of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=login_link", headers: headers2
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'with 422 status if user tries to request stripe dashboard link of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=login_link", headers: headers2
      expect(response.status).to eq 422
    end

    it 'with relevant error if user is not authenticated and requests stripe dashboard link' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=login_link", headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'with 401 status if user is not authenticated and requests stripe dashboard link' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=login_link", headers: not_headers
      expect(response.status).to eq 401
    end

    it 'with relevant error if user is not authenticated and creates a stripe payment intent' do
      get '/api/v1/stripe?occasion=create_payment_intent', headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'with 401 status if user is not authenticated and creates a stripe payment intent' do
      get '/api/v1/stripe?occasion=create_payment_intent', headers: not_headers
      expect(response.status).to eq 401
    end

    it 'with relevant error if user is not authenticated and updates a stripe payment intent' do
      get '/api/v1/stripe?occasion=update_payment_intent', headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'with 401 status if user is not authenticated and updates a stripe payment intent' do
      get '/api/v1/stripe?occasion=update_payment_intent', headers: not_headers
      expect(response.status).to eq 401
    end

    it 'with relevant error if user is not authenticated and requests stripe account deletion' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'with 401 status if user is not authenticated and requests stripe account deletion' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: not_headers
      expect(response.status).to eq 401
    end

    it 'with relevant error if user tries to request stripe account deletion of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: headers2
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'with 422 status if user tries to request stripe account deletion of another user' do
      get "/api/v1/stripe?host_profile_id=#{profile_user.id}&occasion=delete_account", headers: headers2
      expect(response.status).to eq 422
    end

    it 'with relevant custom error if user tries to request stripe account deletion of account that does not exist' do
      get "/api/v1/stripe?host_profile_id=#{profile_user2.id}&occasion=delete_account", headers: headers2
      expect(
        json_response['error']
      ).to eq 'There was a problem connecting to our payments infrastructure provider. Please try again later.'
    end

    it 'with 555 custom status if user tries to request stripe account deletion of account that does not exist' do
      get "/api/v1/stripe?host_profile_id=#{profile_user2.id}&occasion=delete_account", headers: headers2
      expect(response.status).to eq 555
    end
  end
end
