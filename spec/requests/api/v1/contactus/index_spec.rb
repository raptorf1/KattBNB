RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe 'User can fill contact us form in the front-end and API', type: :request do
  it 'responds with 200 if email is valid' do
    get '/api/v1/contactus?name=Access Token&email=test@hotmail.com&message=Can I order pizza from your website???'
    expect(json_response['message']).to eq 'Success!!!'
    expect(response.status).to eq 200
  end

  it 'responds with 422 if email is invalid' do
    get '/api/v1/contactus?name=Access Token&email=tefgdgst@hotjgjmail.com&message=Can I order pizza from your website???'
    expect(json_response['error']).to eq [
         "There was a problem validating your email! You sure it's the right one? You can always find us by following our social media links below."
       ]
    expect(response.status).to eq 422
  end
end
