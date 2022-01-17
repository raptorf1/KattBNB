RSpec.describe 'PATCH /api/v1/conversations/id', type: :request do
  let(:user1) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:credentials_user1) { user1.create_new_auth_token }
  let(:headers_user1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user1) }

  let(:user2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:credentials_user2) { user2.create_new_auth_token }
  let(:headers_user2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user2) }

  let(:user3) { FactoryBot.create(:user, email: 'faraz@craft.com', nickname: 'EarlyInTheMorning') }
  let(:credentials_user3) { user3.create_new_auth_token }
  let(:headers_user3) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user3) }

  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id, hidden: nil) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id, hidden: user1.id) }

  describe 'succesfully' do
    before do
      patch "/api/v1/conversations/#{conversation1.id}", params: { hidden: user1.id }, headers: headers_user1
      conversation1.reload
    end

    it 'with 200 status updates hidden field of certain conversation if action comes from associated host' do
      expect(response.status).to eq 200
    end

    it 'with relevant message updates hidden field of certain conversation if action comes from associated host' do
      expect(json_response['message']).to eq 'Success!'
    end

    it 'with correct user id in the hidden field of the updated conversation' do
      expect(conversation1.hidden).to eq user1.id
    end
  end

  describe 'succesfully deletes conversation' do
    before { patch "/api/v1/conversations/#{conversation2.id}", params: { hidden: user2.id }, headers: headers_user3 }

    it 'with 204 status if hidden field is not nil' do
      expect(response.status).to eq 204
    end

    it 'and leaves correct number of conversations in the database' do
      expect(Conversation.all.length).to eq 1
    end

    it 'and leaves the coorect coversation in the database' do
      expect(Conversation.first.id).to eq conversation1.id
    end
  end

  describe 'unsuccessfully for hidden field' do
    before { patch "/api/v1/conversations/#{conversation1.id}", params: { hidden: user3.id }, headers: headers_user3 }

    it 'with 422 status if action comes from an unassociated host' do
      expect(response.status).to eq 422
    end

    it 'with relevant error if action comes from an unassociated host' do
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end
  end

  describe 'unusccessfully for user authentication' do
    before { patch "/api/v1/conversations/#{conversation1.id}", headers: headers_no_auth }

    it 'with 401 status if user is not authenticated' do
      expect(response.status).to eq 401
    end

    it 'with relevant error if user is not authenticated' do
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
