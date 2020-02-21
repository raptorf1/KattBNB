RSpec.describe Conversation, type: :model do
  it 'should have a valid Factory' do
    expect(create(:conversation)).to be_valid
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

  describe "Relations" do
    it { is_expected.to have_many(:message) }
  end

  describe 'Delete dependent setting' do
    it 'conversation is nullified when associated user is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@cyprus.com', nickname: 'george')
      user2 = FactoryBot.create(:user, email: 'zane@sweden.com', nickname: 'zane')
      user3 = FactoryBot.create(:user, email: 'boa@norway.com', nickname: 'boa')
      conversation1 = FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id)
      conversation2 = FactoryBot.create(:conversation, user1_id: user3.id, user2_id: user1.id)
      conversation3 = FactoryBot.create(:conversation, user1_id: user2.id, user2_id: user3.id)
      expect(Conversation.all.length).to eq 3
      expect(User.all.length).to eq 3
      user1.destroy
      conversation1.reload
      conversation2.reload
      expect(Conversation.all.length).to eq 3
      expect(User.all.length).to eq 2
      expect(conversation1.user1_id).to eq nil
      expect(conversation1.user2_id).to eq user2.id
      expect(conversation2.user1_id).to eq user3.id
      expect(conversation2.user2_id).to eq nil
    end
  end
end
