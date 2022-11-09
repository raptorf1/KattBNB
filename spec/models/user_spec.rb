RSpec.describe User, type: :model do
  describe "Factory" do
    it "should be valid" do
      expect(create(:user)).to be_valid
    end
  end

  describe "Callbacks" do
    it "should have a remove whitespace method in before_create" do
      expect(
        User
          ._create_callbacks
          .select { |cb| cb.kind.eql?(:before) }
          .collect(&:filter)
          .include?(:remove_whitespace_nickname)
      ).to eq true
    end

    it "should remove whitespace on nickname" do
      user = FactoryBot.create(:user, nickname: " Fernando Alonso   ")
      expect(user.nickname).to eq "Fernando Alonso"
    end
  end

  describe "Database table" do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :provider }
    it { is_expected.to have_db_column :uid }
    it { is_expected.to have_db_column :encrypted_password }
    it { is_expected.to have_db_column :reset_password_token }
    it { is_expected.to have_db_column :reset_password_sent_at }
    it { is_expected.to have_db_column :allow_password_change }
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

  describe "Validations" do
    it { is_expected.to validate_presence_of :nickname }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :password }
    it { is_expected.to validate_presence_of :location }
    it { is_expected.to validate_confirmation_of :password }

    context "should not have an invalid email address" do
      emails = [
        "stefan@ craft.com",
        "@felix.com",
        "test mail@gmail.com",
        "user@mail",
        "foobar@.yo. .yo",
        "wazzup@.dawg",
        "  wazz up@.daw g     "
      ]

      emails.each { |email| it { is_expected.not_to allow_value(email).for(:email) } }
    end

    context "should have a valid email address" do
      emails = %w[felix@craft.com foobar@craft.co.uk carla123@craft.se george@craft.gr]

      emails.each { |email| it { is_expected.to allow_value(email).for(:email) } }
    end

    it "nickname should be case insensitive and unique" do
      FactoryBot.create(:user, nickname: "Mick")
      expect { FactoryBot.create(:user, nickname: "MICK") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "Relations" do
    it { is_expected.to have_one(:host_profile) }
    it { is_expected.to have_many(:booking) }
    it { is_expected.to have_many(:conversation1) }
    it { is_expected.to have_many(:conversation2) }
    it { is_expected.to have_many(:message) }
    it { is_expected.to have_many(:review) }
    it { is_expected.to have_one(:profile_avatar_attachment) }
  end

  describe "Attached image" do
    before do
      @user = FactoryBot.create(:user)
      @user.profile_avatar.attach(
        io: File.open("spec/fixtures/greece.jpg"),
        filename: "attachment.jpg",
        content_type: "image/jpg"
      )
    end

    it "is successfully attached" do
      expect(@user.profile_avatar).to be_attached
    end

    it "is deleted when relevant user is deleted" do
      @user.destroy
      expect(ActiveStorage::Attachment.all.length).to eq 0
    end
  end

  describe "Delete dependent settings" do
    it "host profile is deleted when associated user is deleted from the database" do
      FactoryBot.create(:host_profile)
      HostProfile.last.user.destroy
      expect(HostProfile.all.length).to eq 0
    end

    it "user association of message is nullified when associated user is deleted from the database" do
      FactoryBot.create(:message)
      Message.last.user.destroy
      expect(Message.last.user_id).to eq nil
    end

    it "booking is deleted when associated user is deleted from the database" do
      FactoryBot.create(:booking)
      Booking.last.user.destroy
      expect(Booking.all.length).to eq 0
    end

    it "review is nullified when associated user is deleted" do
      FactoryBot.create(:review)
      Review.last.user.destroy
      expect(Review.last.user_id).to eq nil
    end

    it "conversation is nullified when associated user is deleted from the database" do
      FactoryBot.create(:conversation)
      Conversation.last.user1.destroy
      expect(Conversation.last.user1_id).to eq nil
    end
  end
end
