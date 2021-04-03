RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe 'User Account Deletion', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  it 'returns a user and a token and then deletes user from the database' do
    post '/api/v1/auth',
         params: {
           email: 'zane@craft.se',
           password: 'password',
           password_confirmation: 'password',
           nickname: 'KittenPrincess',
           location: 'Gothenburg',
           confirm_success_url: 'confirmed'
         },
         headers: headers

    User.last.update_attribute(:confirmed_at, '2019-08-10 09:56:34.588757')

    post '/api/v1/auth/sign_in', params: { email: 'zane@craft.se', password: 'password' }, headers: headers

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']

    delete '/api/v1/auth',
           params: {
             uid: new_user_uid,
             'access-token': new_user_token,
             client: new_user_client
           },
           headers: headers

    expect(json_response['status']).to eq 'success'
    expect(response.status).to eq 200
    expect(User.all.length).to eq 0
  end

  it 'returns a user and a token and then deletes user from the database in under 1ms and with iteration rate of 2000000 per second' do
    post '/api/v1/auth',
         params: {
           email: 'zane@craft.se',
           password: 'password',
           password_confirmation: 'password',
           nickname: 'KittenPrincess',
           location: 'Gothenburg',
           confirm_success_url: 'confirmed'
         },
         headers: headers

    User.last.update_attribute(:confirmed_at, '2019-08-10 09:56:34.588757')

    post '/api/v1/auth/sign_in', params: { email: 'zane@craft.se', password: 'password' }, headers: headers

    new_user_uid = response.headers['uid']
    new_user_token = response.headers['access-token']
    new_user_client = response.headers['client']

    delete_request =
      delete '/api/v1/auth',
             params: {
               uid: new_user_uid,
               'access-token': new_user_token,
               client: new_user_client
             },
             headers: headers
    expect { delete_request }.to perform_under(1).ms.sample(20).times
    expect { delete_request }.to perform_at_least(2_000_000).ips
  end
end
