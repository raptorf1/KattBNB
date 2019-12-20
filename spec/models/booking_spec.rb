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
    it { is_expected.to have_db_column :host_avatar }
    it { is_expected.to have_db_column :host_real_lat }
    it { is_expected.to have_db_column :host_real_long }
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

  describe 'Default values' do
    it 'returns Array as class for dates field' do
      FactoryBot.create(:booking)
      expect(Booking.last.dates.class).to eq Array
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

    it 'pending booking is deleted and host profile availability is altered when associated user is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso')
      user2 = FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten')
      host_profile_user2 = FactoryBot.create(:host_profile, user_id: user2.id, availability: [1, 2, 3, 4, 5])
      booking = FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user1.id, status: 'pending', dates: [1562889600000, 1562976000000])
      user1.destroy
      host_profile_user2.reload
      expect(host_profile_user2.availability).to eq [1, 2, 3, 4, 5, 1562889600000, 1562976000000]
    end

    it 'accepted upcoming booking is deleted and a notification email is sent to the host when associated user is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso')
      user2 = FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten')
      booking = FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user1.id, status: 'accepted', dates: [2562889600000, 2562976000000])
      user1.destroy
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'accepted past booking is deleted when associated user is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso')
      user2 = FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten')
      booking = FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user1.id, status: 'accepted', dates: [1462889600000, 1462976000000])
      user1.destroy
      expect(Booking.all.length).to eq 0
    end
  end

end
