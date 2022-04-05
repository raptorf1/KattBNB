RSpec.describe Booking, type: :model do
  describe 'Factory' do
    it 'should be valid' do
      User.destroy_all
      expect(create(:booking)).to be_valid
    end
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :number_of_cats }
    it { is_expected.to have_db_column :message }
    it { is_expected.to have_db_column :host_message }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :status }
    it { is_expected.to have_db_column :host_nickname }
    it { is_expected.to have_db_column :dates }
    it { is_expected.to have_db_column :price_per_day }
    it { is_expected.to have_db_column :price_total }
    it { is_expected.to have_db_column :host_description }
    it { is_expected.to have_db_column :host_full_address }
    it { is_expected.to have_db_column :host_real_lat }
    it { is_expected.to have_db_column :host_real_long }
    it { is_expected.to have_db_column :payment_intent_id }
    it { is_expected.to have_db_column :host_profile_id }
    it { is_expected.to have_db_column :created_at }
    it { is_expected.to have_db_column :updated_at }
    it { is_expected.to have_db_column :paid }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :number_of_cats }
    it { is_expected.to validate_presence_of :message }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :host_nickname }
    it { is_expected.to validate_presence_of :dates }
    it { is_expected.to validate_presence_of :price_per_day }
    it { is_expected.to validate_presence_of :price_total }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_length_of(:message).is_at_most(400) }
    it { is_expected.to validate_length_of(:host_message).is_at_most(200) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Relations' do
    it { is_expected.to have_one(:review) }
  end

  describe 'enum definitions' do
    it { should define_enum_for :status }
  end

  describe 'Default values' do
    it 'returns Array as class for dates field' do
      FactoryBot.create(:booking)
      expect(Booking.last.dates.class).to eq Array
    end

    it "returns false for 'paid' field" do
      FactoryBot.create(:booking)
      expect(Booking.last.paid).to eq false
    end
  end

  describe 'Delete dependent setting' do
    it 'review is nullified when associated booking is deleted' do
      FactoryBot.create(:review)
      Review.last.booking.destroy
      expect(Review.last.booking_id).to eq nil
    end
  end
end
