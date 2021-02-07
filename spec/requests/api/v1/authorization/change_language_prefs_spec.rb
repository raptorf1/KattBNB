RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe 'User Changes Language Preference Information and API', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  it 'returns a user and a token and then changes the language preference' do
    post '/api/v1/auth',
         params: {
           email: 'felix@craft.se',
           password: 'password',
           password_confirmation: 'password',
           nickname: 'FlavioB',
           location: 'Tokyo',
           lang_pref: 'sv-SE',
           confirm_success_url: 'confirmed'
         },
         headers: headers

    User.last.update_attribute(:confirmed_at, '2019-08-10 09:56:34.588757')

    post '/api/v1/auth/sign_in', params: { email: 'felix@craft.se', password: 'password' }, headers: headers

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']
    new_user_id = json_response['data']['id']

    put '/api/v1/auth',
        params: {
          lang_pref: 'en-US',
          uid: new_user_uid,
          'access-token': new_user_token,
          client: new_user_client
        },
        headers: headers
    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200
    expect(json_response['data']['lang_pref']).to eq 'en-US'
  end

  it 'returns a user and a token and then changes the language preference in under 1 ms and with iteration rate of 5000000 per second' do
    post '/api/v1/auth',
         params: {
           email: 'felix@craft.se',
           password: 'password',
           password_confirmation: 'password',
           nickname: 'FlavioB',
           location: 'Tokyo',
           lang_pref: 'sv-SE',
           confirm_success_url: 'confirmed'
         },
         headers: headers

    User.last.update_attribute(:confirmed_at, '2019-08-10 09:56:34.588757')

    post '/api/v1/auth/sign_in', params: { email: 'felix@craft.se', password: 'password' }, headers: headers

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']
    new_user_id = json_response['data']['id']

    put_request =
      put '/api/v1/auth',
          params: {
            lang_pref: 'en-US',
            uid: new_user_uid,
            'access-token': new_user_token,
            client: new_user_client
          },
          headers: headers
    expect { put_request }.to perform_under(1).ms.sample(20).times
    expect { put_request }.to perform_at_least(5_000_000).ips
  end
end
