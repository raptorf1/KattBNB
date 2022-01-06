RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe 'User Changes Language Preference Information and API', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }
  let(:user) { FactoryBot.create(:user, lang_pref: 'sv-SE')}
  let(:auth_token) { user.create_new_auth_token }

  describe 'returns a user and a token and then changes the language preference' do
    before do
      @put_request = put '/api/v1/auth',
      params: {
        lang_pref: 'en-US',
        uid: user.uid,
        'access-token': auth_token['access-token'],
        client: auth_token['client']
      },
      headers: headers
    end

    it 'is expected to return a success message' do      
      expect(json_response['status']).to eq 'success'
    end

    it "is expected to return a 200 response status" do
      expect(response.status).to eq 200
    end

    it "is expected to return new language preference" do
      expect(json_response['data']['lang_pref']).to eq 'en-US' 
    end

    it "is expected to change the language preference in under 1 ms and with iteration rate of 2000000 per second" do
      expect { @put_request }.to perform_under(1).ms.sample(20).times
      expect { @put_request }.to perform_at_least(2_000_000).ips  
    end
  end
end
