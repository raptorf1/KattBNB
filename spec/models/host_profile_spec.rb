RSpec.describe HostProfile, type: :model do
  describe 'Factory' do
    it 'should be valid' do
      expect(create(:host_profile)).to be_valid
    end
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :full_address }
    it { is_expected.to have_db_column :price_per_day_1_cat }
    it { is_expected.to have_db_column :supplement_price_per_cat_per_day }
    it { is_expected.to have_db_column :max_cats_accepted }
    it { is_expected.to have_db_column :availability }
    it { is_expected.to have_db_column :lat }
    it { is_expected.to have_db_column :long }
    it { is_expected.to have_db_column :latitude }
    it { is_expected.to have_db_column :longitude }
    it { is_expected.to have_db_column :score }
    it { is_expected.to have_db_column :stripe_state }
    it { is_expected.to have_db_column :stripe_account_id }
    it { is_expected.to have_db_column :created_at }
    it { is_expected.to have_db_column :updated_at }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :full_address }
    it { is_expected.to validate_presence_of :price_per_day_1_cat }
    it { is_expected.to validate_presence_of :supplement_price_per_cat_per_day }
    it { is_expected.to validate_presence_of :max_cats_accepted }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:review) }
  end

  describe 'Default values' do
    it 'returns Array as class for availability field' do
      FactoryBot.create(:host_profile)
      expect(HostProfile.last.availability.class).to eq Array
    end
  end

  describe 'Delete dependent setting' do
    it 'review is nullified when associated host profile is deleted' do
      FactoryBot.create(:review)
      Review.last.host_profile.destroy
      expect(Review.last.host_profile_id).to eq nil
    end
  end
end
