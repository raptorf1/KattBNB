RSpec.describe 'GET /v0/pings', type: :request do
  describe 'succesfully' do
    before { get '/api/v0/pings' }

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with correct message' do
      expect(json_response['message']).to eq 'Meow!'
    end
  end
end
