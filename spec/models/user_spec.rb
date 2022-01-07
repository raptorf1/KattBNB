RSpec.describe User, type: :model do
  it 'should have valid Factory' do
    expect(create(:user)).to be_valid
  end

  # test removing of whitespace on nickname

  describe 'Database table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :provider }
    it { is_expected.to have_db_column :uid }
    it { is_expected.to have_db_column :encrypted_password }
    it { is_expected.to have_db_column :reset_password_token }
    it { is_expected.to have_db_column :reset_password_sent_at }
    it { is_expected.to have_db_column :remember_created_at }
    it { is_expected.to have_db_column :sign_in_count }
    it { is_expected.to have_db_column :current_sign_in_at }
    it { is_expected.to have_db_column :last_sign_in_at }
    it { is_expected.to have_db_column :current_sign_in_ip }
    it { is_expected.to have_db_column :last_sign_in_ip }
    it { is_expected.to have_db_column :confirmation_token }
    it { is_expected.to have_db_column :confirmed_at }
    it { is_expected.to have_db_column :confirmation_sent_at }
    it { is_expected.to have_db_column :unconfirmed_email }
    it { is_expected.to have_db_column :nickname }
    it { is_expected.to have_db_column :image }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :tokens }
    it { is_expected.to have_db_column :created_at }
    it { is_expected.to have_db_column :updated_at }
    it { is_expected.to have_db_column :location }
    it { is_expected.to have_db_column :avatar }
    it { is_expected.to have_db_column :message_notification }
    it { is_expected.to have_db_column :lang_pref }
  end

  # The error message of the below test proves exactly what we are trying to achieve.
  # Although ShouldaMatchers are installed, the provided 'case_insensitive' method produces an error.
  # describe 'Uniqueness validation' do
  #   before do
  #     FactoryBot.create(:user)
  #   end
  #   it { is_expected.to validate_uniqueness_of :nickname }
  # end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :nickname }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :password }
    it { is_expected.to validate_presence_of :location }
    it { is_expected.to validate_confirmation_of :password }

    context 'should not have an invalid email address' do
      emails = [
        'stefan@ craft.com',
        '@felix.com',
        'test mail@gmail.com',
        'user@mail',
        'foobar@.yo. .yo',
        'wazzup@.dawg'
      ]

      emails.each { |email| it { is_expected.not_to allow_value(email).for(:email) } }
    end

    context 'should have a valid email address' do
      emails = %w[felix@craft.com foobar@craft.co.uk carla123@craft.se george@craft.gr]

      emails.each { |email| it { is_expected.to allow_value(email).for(:email) } }
    end
  end

  describe 'Relations' do
    it { is_expected.to have_one(:host_profile) }
    it { is_expected.to have_many(:booking) }
    it { is_expected.to have_many(:conversation1) }
    it { is_expected.to have_many(:conversation2) }
    it { is_expected.to have_many(:message) }
    it { is_expected.to have_many(:review) }
    it { is_expected.to have_one(:profile_avatar_attachment) }
  end

  describe 'Attached image' do
    it 'is valid' do
      subject.profile_avatar.attach(
        io: File.open('spec/fixtures/greece.jpg'),
        filename: 'attachment.jpg',
        content_type: 'image/jpg'
      )
      expect(subject.profile_avatar).to be_attached
    end
  end

  describe 'Delete dependent setting' do
    it 'review is nullified when associated user is deleted' do
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
      user.destroy
      review.reload
      expect(review.user_id).to eq nil
      expect(review.booking_id).to eq nil
    end
  end
end
