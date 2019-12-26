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
end
