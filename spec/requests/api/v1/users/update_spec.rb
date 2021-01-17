RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe 'User Saves / Changes Avatar and API', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let!(:user2) { FactoryBot.create(:user, email: 'a@a.com', nickname: 'Rails is king!') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: "application/json" }.merge!(credentials2) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  it 'saves the avatar in ActiveStorage' do

    expect(user.profile_avatar.attached?).to eq false

    put "/api/v1/users/#{user.id}", params: {
                                  profile_avatar: {
                                        type: "image/png",
                                        encoder: "name=carbon (5).png;base64",
                                        data: "iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf",
                                        extension: "png" 
                                      },
                                  'access-token': headers['access-token'],
                                  client: headers['client']
                               }, headers: headers
    expect(json_response['message']).to eq 'Successfully updated!'
    expect(response.status).to eq 200
    user.reload
    expect(user.profile_avatar.attached?).to eq true
  end

  it 'does not save the avatar in ActiveStorage if token/client expires or is invalid' do

    expect(user.profile_avatar.attached?).to eq false

    put "/api/v1/users/#{user.id}", params: {
                                  profile_avatar: {
                                        type: "image/png",
                                        encoder: "name=carbon (5).png;base64",
                                        data: "iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf",
                                        extension: "png" 
                                      },
                                  'access-token': 'kjhfvHTghjjhjbjk',
                                  client: headers['client']
                               }, headers: headers
    expect(json_response['error']).to eq ['You cannot perform this action!']
    expect(response.status).to eq 422
    user.reload
    expect(user.profile_avatar.attached?).to eq false
  end

  it 'raises an error if no token/client params are passed' do

    expect(user.profile_avatar.attached?).to eq false

    put "/api/v1/users/#{user.id}", params: {
                                  profile_avatar: {
                                        type: "image/png",
                                        encoder: "name=carbon (5).png;base64",
                                        data: "iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf",
                                        extension: "png" 
                                      }
                               }, headers: headers
    expect(json_response['error']).to eq ['You cannot perform this action!']
    expect(response.status).to eq 422
    user.reload
    expect(user.profile_avatar.attached?).to eq false
  end  

  it 'saves the avatar in ActiveStorage in under 1 ms and with iteration rate of 3000000 per second' do

    put_request = put "/api/v1/users/#{user.id}", params: {
      profile_avatar: {
            type: "image/png",
            encoder: "name=carbon (5).png;base64",
            data: "iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf",
            extension: "png" 
          },
      'access-token': headers['access-token'],
      client: headers['client']
   }, headers: headers
    expect { put_request }.to perform_under(1).ms.sample(20).times
    expect { put_request }.to perform_at_least(3000000).ips
  end

  it 'raises an error if user is not signed in' do

    put "/api/v1/users/#{user.id}", params: {
                                  profile_avatar: {
                                        type: "image/png",
                                        encoder: "name=carbon (5).png;base64",
                                        data: "iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf",
                                        extension: "png" 
                                      },
                                  'access-token': headers['access-token'],
                                  client: headers['client']
                               }, headers: not_headers
    expect(json_response['errors']).to eq ["You need to sign in or sign up before continuing."]
  end

  it "raises an error if user tries to update someone else's avatar" do

    expect(user.profile_avatar.attached?).to eq false

    put "/api/v1/users/#{user.id}", params: {
                                  profile_avatar: {
                                        type: "image/png",
                                        encoder: "name=carbon (5).png;base64",
                                        data: "iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf",
                                        extension: "png" 
                                      },
                                  'access-token': headers['access-token'],
                                  client: headers['client']
                               }, headers: headers2
    expect(json_response['error']).to eq ['You cannot perform this action!']
    expect(response.status).to eq 422
    user.reload
    expect(user.profile_avatar.attached?).to eq false
  end

  # If we remove the ternanry at line 4 of the DecodeImageService file,
  # we can also successfully test line 13 of update action in Users controller.

end
