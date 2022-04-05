RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  describe 'successfully' do
    it 'connects' do
      User.destroy_all
      connect "/cable/conversation/5?token=#{headers['access-token']}&uid=#{headers['uid']}&client=#{headers['client']}"
      expect(connection.current_user.id).to eq user.id
    end
  end

  describe 'unsuccessfully' do
    it 'rejects connection if invalid params are passed' do
      expect {
        connect '/cable/conversation/5?token=sfbbfjhdjfb&uid=batman@robin.com&client=djfnjkdvjfbfjdfnjgnfkmv'
      }.to have_rejected_connection
    end

    it 'rejects connection if no params are passed' do
      expect { connect '/cable/conversation/5' }.to have_rejected_connection
    end
  end
end
