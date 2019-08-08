RSpec.describe 'User Changes Password and API', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  it 'returns a user and a token and then changes the user password' do
    expect(User.all.length).to eq 0
    post '/api/v1/auth', params: { email: 'zane@craft.se',
                                   password: 'password',
                                   password_confirmation: 'password',
                                   nickname: 'KittenPrincess',
                                   location: 'Gothenburg'
                                }, headers: headers

    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200
    expect(User.all.length).to eq 1

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']

    put '/api/v1/auth', params: { current_password: 'password',
                                  password: '123456',
                                  password_confirmation: '123456',
                                  uid: new_user_uid,
                                  'access-token': new_user_token,
                                  client: new_user_client
                                 }, headers: headers
    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200

    post "/api/v1/auth/sign_in", params: { email: 'zane@craft.se',
                                           password: '123456'
                                         }, headers: headers
 
    expect(response.status).to eq 200
    expect(User.all.length).to eq 1

    post "/api/v1/auth/sign_in", params: { email: 'zane@craft.se',
                                           password: 'password'
                                        }, headers: headers
    expect(response.status).to eq 401
    expect(json_response['errors']).to eq ['Invalid login credentials. Please try again.']
    expect(User.all.length).to eq 1
  end

  
  it 'does not allow password change if current password is incorrect' do
    expect(User.all.length).to eq 0
    post '/api/v1/auth', params: { email: 'george@craft.se',
                                   password: 'passwordG',
                                   password_confirmation: 'passwordG',
                                   nickname: 'F1',
                                   location: 'Thessaloniki'
                                }, headers: headers

    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200
    expect(User.all.length).to eq 1

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']

    put '/api/v1/auth', params: { current_password: 'password',
                                  password: '123456',
                                  password_confirmation: '123456',
                                  uid: new_user_uid,
                                  'access-token': new_user_token,
                                  client: new_user_client
                                 }, headers: headers
    expect(json_response['status']).to eq 'error'
    expect(response.status).to eq 422
    expect(json_response['errors']['full_messages']).to eq ['Current password is invalid']
    expect(User.all.length).to eq 1
  end


  it 'does not allow password change if new password and password confirmation do not match' do
    expect(User.all.length).to eq 0
    post '/api/v1/auth', params: { email: 'carla@craft.se',
                                   password: 'passwordC',
                                   password_confirmation: 'passwordC',
                                   nickname: 'singer',
                                   location: 'Stockholm'
                                }, headers: headers

    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200
    expect(User.all.length).to eq 1

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']

    put '/api/v1/auth', params: { current_password: 'passwordC',
                                  password: '123456a',
                                  password_confirmation: '123456',
                                  uid: new_user_uid,
                                  'access-token': new_user_token,
                                  client: new_user_client
                                 }, headers: headers
    expect(json_response['status']).to eq 'error'
    expect(response.status).to eq 422
    expect(json_response['errors']['full_messages']).to eq ["Password confirmation doesn't match Password"]
    expect(User.all.length).to eq 1
  end

end
