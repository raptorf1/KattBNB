RSpec.describe 'User Changes Password', type: :request do
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

  end
end
