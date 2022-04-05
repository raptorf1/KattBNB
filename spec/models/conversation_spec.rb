RSpec.describe Conversation, type: :model do
  describe 'Factory' do
    it 'should be valid' do
      User.destroy_all
      expect(create(:conversation)).to be_valid
    end
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :user1_id }
    it { is_expected.to have_db_column :user2_id }
    it { is_expected.to have_db_column :hidden }
    it { is_expected.to have_db_column :created_at }
    it { is_expected.to have_db_column :updated_at }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :user1_id }
    it { is_expected.to validate_presence_of :user2_id }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user1) }
    it { is_expected.to belong_to(:user2) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:message) }
  end

  describe 'Delete dependent setting' do
    it 'message is deleted when associated conversation is deleted from the database' do
      FactoryBot.create(:message)
      Message.last.conversation.destroy
      expect(Message.all.length).to eq 0
    end
  end
end
