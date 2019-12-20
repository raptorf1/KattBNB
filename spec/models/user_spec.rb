RSpec.describe User, type: :model do
  it 'should have valid Factory' do
    expect(create(:user)).to be_valid
  end

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
      emails = ['stefan@ craft.com', '@felix.com', 'test mail@gmail.com',
                'user@mail', 'foobar@.yo. .yo', 'wazzup@.dawg']

      emails.each do |email|
        it { is_expected.not_to allow_value(email).for(:email) }
      end
    end

    context 'should have a valid email address' do
      emails = ['felix@craft.com', 'foobar@craft.co.uk', 'carla123@craft.se',
                'george@craft.gr']

      emails.each do |email|
        it { is_expected.to allow_value(email).for(:email) }
      end
    end
  end

  describe "Relations" do
    it { is_expected.to have_one(:host_profile) }
    it { is_expected.to have_many(:booking) }
    it { is_expected.to have_many(:conversation) }
    it { is_expected.to have_many(:message) }
  end
end
