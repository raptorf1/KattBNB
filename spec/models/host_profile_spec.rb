RSpec.describe HostProfile, type: :model do
  it 'should have valid Factory' do
    expect(create(:host_profile)).to be_valid
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :full_address }
    it { is_expected.to have_db_column :price_per_day_1_cat }
    it { is_expected.to have_db_column :supplement_price_per_cat_per_day }
    it { is_expected.to have_db_column :max_cats_accepted }
    it { is_expected.to have_db_column :availability }
    it { is_expected.to have_db_column :lat }
    it { is_expected.to have_db_column :long }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :full_address }
    it { is_expected.to validate_presence_of :price_per_day_1_cat }
    it { is_expected.to validate_presence_of :supplement_price_per_cat_per_day }
    it { is_expected.to validate_presence_of :max_cats_accepted }
    it { is_expected.to validate_presence_of :availability }
    it { is_expected.to validate_presence_of :lat }
    it { is_expected.to validate_presence_of :long }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Default values' do
    it 'returns Array as class for availability field' do
      FactoryBot.create(:host_profile)
      expect(HostProfile.last.availability.class).to eq Array
    end
  end

  describe 'Delete dependent setting' do
    it 'profile is deleted when associated user is deleted from the database' do
      FactoryBot.create(:host_profile)
      expect(HostProfile.all.length).to eq 1
      expect(User.all.length).to eq 1
      User.last.destroy
      expect(HostProfile.all.length).to eq 0
      expect(User.all.length).to eq 0
    end

    it 'user is not deleted when associated profile is deleted from the database' do
      FactoryBot.create(:host_profile)
      expect(HostProfile.all.length).to eq 1
      expect(User.all.length).to eq 1
      HostProfile.last.destroy
      expect(HostProfile.all.length).to eq 0
      expect(User.all.length).to eq 1
    end
  end
end
