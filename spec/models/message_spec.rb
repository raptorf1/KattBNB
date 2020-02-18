RSpec.describe Message, type: :model do
  it 'should have a valid Factory' do
    expect(create(:message)).to be_valid
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :conversation_id }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :body }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_length_of :body }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:conversation) }
  end

  describe 'Delete dependent setting' do
    it 'message is deleted when associated conversation is deleted from the database' do
      FactoryBot.create(:conversation)
      FactoryBot.create(:message, conversation_id: Conversation.last.id)
      expect(Conversation.all.length).to eq 1
      expect(Message.all.length).to eq 1
      Conversation.last.destroy
      expect(Conversation.all.length).to eq 0
      expect(Message.all.length).to eq 0
    end

    it 'user association of message is nullified when associated user is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@cyprus.com', nickname: 'george')
      user2 = FactoryBot.create(:user, email: 'zane@sweden.com', nickname: 'zane')
      FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id)
      FactoryBot.create(:message, user_id: user1.id, conversation_id: Conversation.last.id)
      expect(User.all.length).to eq 2
      expect(Conversation.all.length).to eq 1
      expect(Message.all.length).to eq 1
      user1.destroy
      expect(User.all.length).to eq 1
      expect(Conversation.all.length).to eq 1
      expect(Message.all.length).to eq 1
      expect(Message.last.user_id).to eq nil
    end
  end
end
