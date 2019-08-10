RSpec.describe 'User Changes Password and API', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  before(:each) do
    post '/api/v1/auth', params: { email: 'zane@craft.se',
                                   password: 'password',
                                   password_confirmation: 'password',
                                   nickname: 'KittenPrincess',
                                   location: 'Gothenburg'
                                }, headers: headers

    User.last.update_attribute(:confirmed_at, '2019-08-10 09:56:34.588757')

    post "/api/v1/auth/sign_in", params: { email: 'zane@craft.se',
                                           password: 'password'
                                        }, headers: headers

    @new_user_uid = response.headers['uid']
    @new_user_token = response.headers['access-token']
    @new_user_client = response.headers['client']
  end

  it 'successfully changes the user password and lets user log in with the new password' do
    put '/api/v1/auth/password', params: { current_password: 'password',
                                           password: '123456',
                                           password_confirmation: '123456',
                                           uid: @new_user_uid,
                                           'access-token': @new_user_token,
                                           client: @new_user_client
                                        }, headers: headers

    expect(json_response['success']).to eq true
    expect(response.status).to eq 200

    post "/api/v1/auth/sign_in", params: { email: 'zane@craft.se',
                                           password: '123456'
                                       }, headers: headers
 
    expect(response.status).to eq 200
  end

  it 'successfully changes the user password and does not let user log in with the old password' do
    put '/api/v1/auth/password', params: { current_password: 'password',
                                           password: '123456',
                                           password_confirmation: '123456',
                                           uid: @new_user_uid,
                                           'access-token': @new_user_token,
                                           client: @new_user_client
                                        }, headers: headers

    expect(json_response['success']).to eq true
    expect(response.status).to eq 200

    post "/api/v1/auth/sign_in", params: { email: 'zane@craft.se',
                                           password: 'password'
                                        }, headers: headers
    expect(response.status).to eq 401
    expect(json_response['errors']).to eq ['Invalid login credentials. Please try again.']
  end
  
  it 'does not allow password change if current password is incorrect' do
    put '/api/v1/auth/password', params: { current_password: 'pass',
                                           password: '123456',
                                           password_confirmation: '123456',
                                           uid: @new_user_uid,
                                           'access-token': @new_user_token,
                                           client: @new_user_client
                                        }, headers: headers
    expect(json_response['success']).to eq false
    expect(response.status).to eq 422
    expect(json_response['errors']['full_messages']).to eq ['Current password is invalid']
  end

  it 'does not allow password change if new password and password confirmation do not match' do
    put '/api/v1/auth/password', params: { current_password: 'password',
                                           password: '123456a',
                                           password_confirmation: '123456',
                                           uid: @new_user_uid,
                                           'access-token': @new_user_token,
                                           client: @new_user_client
                                        }, headers: headers
    expect(json_response['success']).to eq false
    expect(response.status).to eq 422
    expect(json_response['errors']['full_messages']).to eq ["Password confirmation doesn't match Password"]
  end
end
