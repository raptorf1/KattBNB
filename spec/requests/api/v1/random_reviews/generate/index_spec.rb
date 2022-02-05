RSpec.describe 'GET /api/v1/random_reviews/generate', type: :request do
  let(:host_profile) { FactoryBot.create(:host_profile) }
  let!(:reviews) { 10.times { FactoryBot.create(:review, host_profile_id: host_profile.id) } }

  describe 'successfully' do
    before { get '/api/v1/random_reviews/generate' }

      it 'with 200 status' do
        binding.pry
        expect(response.status).to eq 200
      end
    
    
  end

  
end
