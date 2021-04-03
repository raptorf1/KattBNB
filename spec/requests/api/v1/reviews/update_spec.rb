RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe Api::V1::ReviewsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'Harley Quinn') }
  let(:user3) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:profile1) { FactoryBot.create(:host_profile, user_id: user2.id) }
  let!(:profile2) { FactoryBot.create(:host_profile, user_id: user3.id) }
  let!(:booking1) { FactoryBot.create(:booking, user_id: user1.id) }
  let!(:booking2) { FactoryBot.create(:booking, user_id: user2.id) }
  let(:review1) do
    FactoryBot.create(
      :review,
      host_nickname: 'Harley Quinn',
      host_reply: nil,
      user_id: user1.id,
      host_profile_id: profile1.id,
      booking_id: booking1.id
    )
  end
  let(:review2) do
    FactoryBot.create(
      :review,
      host_nickname: 'Batman',
      host_reply: nil,
      user_id: user2.id,
      host_profile_id: profile2.id,
      booking_id: booking2.id
    )
  end
  let(:credentials1) { user1.create_new_auth_token }
  let(:credentials2) { user2.create_new_auth_token }
  let(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }
  let(:headers2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials2) }
  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'PATCH /api/v1/reviews/id' do
    describe 'successfully' do
      before { patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2 }

      it 'updates a specific review' do
        expect(json_response['message']).to eq 'Successfully updated!'
      end

      it 'has correct response status' do
        expect(response.status).to eq 200
      end
    end

    describe 'successfully' do
      it 'can update a review even if user has deleted her account' do
        review1.update_attribute(:user_id, nil)
        review1.update_attribute(:booking_id, nil)
        patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
        expect(response.status).to eq 200
        review1.reload
        expect(review1.host_reply).to eq 'Thanks a lot!'
      end
    end

    describe 'unsuccessfully' do
      it 'cannot update a review if not logged in' do
        patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: not_headers
        expect(response.status).to eq 401
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end

      it 'cannot update a review that she is not a part of' do
        patch "/api/v1/reviews/#{review2.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
        expect(response.status).to eq 422
        expect(json_response['error']).to eq ['You cannot perform this action!']
      end

      it 'cannot update a review that already contains a host_reply' do
        review1.update(host_reply: 'Already updated!')
        patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
        expect(response.status).to eq 422
        expect(json_response['error']).to eq ['You cannot perform this action!']
      end
    end

    describe 'performance wise' do
      it 'updates a review in under 1 ms and with iteration rate of 2000000 per second' do
        patch_request =
          patch "/api/v1/reviews/#{review1.id}", params: { host_reply: 'Thanks a lot!' }, headers: headers2
        expect { patch_request }.to perform_under(1).ms.sample(20).times
        expect { patch_request }.to perform_at_least(2_000_000).ips
      end
    end
  end
end
