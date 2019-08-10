RSpec.describe 'User Account Deletion', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  it 'returns a user and a token and then deletes user from the database' do
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
    
    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']

    delete '/api/v1/auth', params: { uid: new_user_uid,
                                     'access-token': new_user_token,
                                     client: new_user_client
                                  }, headers: headers

    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200
    expect(User.all.length).to eq 0
  end
end
