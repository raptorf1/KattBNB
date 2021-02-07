RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe Api::V1::ConversationsController, type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:user2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:user3) { FactoryBot.create(:user, email: 'faraz@craft.com', nickname: 'EarlyInTheMorning') }
  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id, hidden: nil) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id, hidden: user1.id) }
  let(:credentials_user1) { user1.create_new_auth_token }
  let(:credentials_user2) { user2.create_new_auth_token }
  let(:credentials_user3) { user3.create_new_auth_token }
  let(:headers_user1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user1) }
  let(:headers_user2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user2) }
  let(:headers_user3) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user3) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'PATCH /api/v1/conversations/id' do
    it 'updates hidden field of certain conversation if action comes from associated host' do
      patch "/api/v1/conversations/#{conversation1.id}", params: { hidden: user1.id }, headers: headers_user1
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'Success!'
      conversation1.reload
      expect(conversation1.hidden).to eq user1.id
    end

    it 'updates hidden field of certain conversation in under 1 ms and with iteration rate of 5000000 per second' do
      patch_request =
        patch "/api/v1/conversations/#{conversation1.id}", params: { hidden: user1.id }, headers: headers_user1
      expect { patch_request }.to perform_under(1).ms.sample(20).times
      expect { patch_request }.to perform_at_least(5_000_000).ips
    end

    it 'does not update hidden field of certain conversation if action comes from an unassociated host' do
      patch "/api/v1/conversations/#{conversation1.id}", params: { hidden: user3.id }, headers: headers_user3
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'does not update conversation if user is not authenticated' do
      patch "/api/v1/conversations/#{conversation1.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'deletes coversation if hidden field is not nil' do
      expect(Conversation.all.length).to eq 2
      patch "/api/v1/conversations/#{conversation2.id}", params: { hidden: user2.id }, headers: headers_user3
      expect(response.status).to eq 204
      expect(Conversation.all.length).to eq 1
      expect(Conversation.first.id).to eq conversation1.id
    end

    it 'deletes coversation if hidden field is not nil in under 1 ms and with iteration rate of 5000000 per second' do
      patch_request =
        patch "/api/v1/conversations/#{conversation2.id}", params: { hidden: user2.id }, headers: headers_user3
      expect { patch_request }.to perform_under(1).ms.sample(20).times
      expect { patch_request }.to perform_at_least(5_000_000).ips
    end
  end
end
