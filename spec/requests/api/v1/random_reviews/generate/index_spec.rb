RSpec.describe 'GET /api/v1/random_reviews/generate', type: :request do
  let!(:high_score_reviews) { 5.times { FactoryBot.create(:review, score: 5) } }
  let!(:low_score_review) { FactoryBot.create(:review) }

  describe 'successfully: when more than 2 reviews exist' do
    before { get '/api/v1/random_reviews/generate' }

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with correct number of reviews' do
      expect(json_response.length).to eq 3
    end

    it 'with only 5 paw reviews' do
      json_response.each { |review| expect(review['id']).not_to eq low_score_review.id }
    end
  end

  describe 'unsuccessfully: when less than 3 reviews exist' do
    before do
      Review.all.destroy_all
      get '/api/v1/random_reviews/generate'
    end

    it 'with 404 status' do
      expect(response.status).to eq 404
    end

    it 'with relevant error' do
      expect(json_response['error']).to eq 'Not enough 5 paw reviews!'
    end
  end
end
