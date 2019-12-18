RSpec.describe Conversation, type: :model do
  it 'should have a valid Factory' do
    expect(create(:conversation)).to be_valid
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :user1_id }
    it { is_expected.to have_db_column :user2_id }
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
end