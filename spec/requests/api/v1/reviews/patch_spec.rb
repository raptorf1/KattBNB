RSpec.describe 'PATCH /api/v1/reviews/id', type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:credentials1) { user1.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }
  let(:booking1) { FactoryBot.create(:booking, user_id: user1.id) }

  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Quinn') }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let(:booking2) { FactoryBot.create(:booking, user_id: user2.id) }

  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:profile3) { FactoryBot.create(:host_profile, user_id: user3.id) }

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  let(:review1) do
    FactoryBot.create(
      :review,
      host_nickname: 'Harley Quinn',
      host_reply: nil,
      user_id: user1.id,
      host_profile_id: profile2.id,
      booking_id: booking1.id
    )
  end

  let(:review2) do
    FactoryBot.create(
      :review,
      host_nickname: 'Batman',
      host_reply: nil,
      user_id: user2.id,
      host_profile_id: profile3.id,
      booking_id: booking2.id
    )
  end

  describe 'successfully when user and host exist' do
    before { patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2 }

    it 'with relevant message' do
      expect(json_response['message']).to eq 'Successfully updated!'
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end
  end

  describe 'successfully even if the user who wrote the review has deleted their account' do
    before do
      review1.update_attribute(:user_id, nil)
      review1.update_attribute(:booking_id, nil)
      patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
      review1.reload
    end

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with correct host reply' do
      expect(review1.host_reply).to eq 'Thanks a lot!'
    end
  end

  describe 'unsuccessfully' do
    it 'with relevant error message if host is not logged in' do
      patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: not_headers
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'with 401 status if host is not logged in' do
      patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: not_headers
      expect(response.status).to eq 401
    end

    it 'with relevant error message if host tries to update review they are not part of' do
      patch "/api/v1/reviews/#{review2.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
      expect(json_response['error']).to eq ['You cannot perform this action!']
    end

    it 'with 422 status if host tries to update review they are not part of' do
      patch "/api/v1/reviews/#{review2.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
      expect(response.status).to eq 422
    end

    it 'with relevant message if review has already been updated with a host reply' do
      review1.update(host_reply: 'Already updated!')
      patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
      expect(json_response['error']).to eq ['You cannot perform this action!']
    end

    it 'with 422 status if review has already been updated with a host reply' do
      review1.update(host_reply: 'Already updated!')
      patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
      expect(response.status).to eq 422
    end
  end
end
