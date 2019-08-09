RSpec.describe 'User Changes Location Information and API', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  it 'returns a user and a token and then changes the location' do
    expect(User.all.length).to eq 0
    post '/api/v1/auth', params: { email: 'felix@craft.se',
                                   password: 'password',
                                   password_confirmation: 'password',
                                   nickname: 'FlavioB',
                                   location: 'Tokyo'
                                }, headers: headers
    expect(json_response['status']).to eq 'success'
    expect(json_response['data']['location']).to eq 'Tokyo'
    expect(response.status).to eq 200
    expect(User.all.length).to eq 1

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']
    new_user_id = json_response['data']['id']

    put '/api/v1/auth', params: { current_password: 'password',
                                  location: 'Japan',
                                  uid: new_user_uid,
                                  'access-token': new_user_token,
                                  client: new_user_client
                                 }, headers: headers
    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200
    expect(json_response['data']['location']).to eq 'Japan'

    post "/api/v1/auth/sign_in", params: { email: 'felix@craft.se',
                                           password: 'password'
                                         }, headers: headers 
    expect(response.status).to eq 200
    expect(User.all.length).to eq 1

    expected_response = {
      "data" => {
        "id" => new_user_id, "uid" => 'felix@craft.se', "email" => 'felix@craft.se',
        "provider" => "email", "name" => nil, "nickname" => 'FlavioB',
        "location" => 'Japan', "image" => nil, "allow_password_change" => false
      }
    }

    expect(json_response).to eq expected_response
  end

end
