RSpec.describe Booking, type: :model do
  it 'should have valid Factory' do
    expect(create(:booking)).to be_valid
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :number_of_cats }
    it { is_expected.to have_db_column :message }
    it { is_expected.to have_db_column :host_message }
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
    it { is_expected.to validate_length_of :message }
    it { is_expected.to validate_length_of :host_message }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Relations' do
    it { is_expected.to have_one(:review) }
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
    it 'canceled booking is deleted when associated user is deleted from the database' do
      FactoryBot.create(:booking, status: 'canceled')
      expect(Booking.all.length).to eq 1
      expect(User.all.length).to eq 1
      User.last.destroy
      expect(Booking.all.length).to eq 0
      expect(User.all.length).to eq 0
    end

    it 'user is not deleted when associated declined booking is deleted from the database' do
      FactoryBot.create(:booking, status: 'declined')
      expect(Booking.all.length).to eq 1
      expect(User.all.length).to eq 1
      Booking.last.destroy
      expect(Booking.all.length).to eq 0
      expect(User.all.length).to eq 1
    end

    it 'accepted past booking is deleted when associated user is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso')
      user2 = FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten')
      booking =
        FactoryBot.create(
          :booking,
          host_nickname: user2.nickname,
          user_id: user1.id,
          status: 'accepted',
          dates: [1_462_889_600_000, 1_462_976_000_000]
        )
      user1.destroy
      expect(Booking.all.length).to eq 0
    end

    it 'review is nullified when associated booking is deleted' do
      user = FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso')
      host = FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten')
      profile = FactoryBot.create(:host_profile, user_id: host.id)
      booking =
        FactoryBot.create(
          :booking,
          host_nickname: host.nickname,
          user_id: user.id,
          status: 'accepted',
          dates: [1_462_889_600_000, 1_462_976_000_000]
        )
      review = FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking.id)
      booking.destroy
      review.reload
      expect(review.booking_id).to eq nil
    end
  end
end
