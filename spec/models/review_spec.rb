RSpec.describe Review, type: :model do
  it 'should have valid Factory' do
    User.destroy_all
    expect(create(:review)).to be_valid
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :score }
    it { is_expected.to have_db_column :body }
    it { is_expected.to have_db_column :host_reply }
    it { is_expected.to have_db_column :host_nickname }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :host_profile_id }
    it { is_expected.to have_db_column :booking_id }
    it { is_expected.to have_db_column :created_at }
    it { is_expected.to have_db_column :updated_at }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :score }
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_presence_of :host_nickname }
    it { is_expected.to validate_numericality_of(:score).only_integer }
    it { is_expected.to validate_numericality_of(:score).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:score).is_less_than_or_equal_to(5) }
    it { is_expected.to validate_length_of(:body).is_at_most(1000) }
    it { is_expected.to validate_length_of(:host_reply).is_at_most(1000) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:host_profile) }
    it { is_expected.to belong_to(:booking) }
  end
end
