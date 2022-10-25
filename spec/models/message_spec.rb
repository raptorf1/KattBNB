RSpec.describe Message, type: :model do
  describe "Factory" do
    it "should be valid" do
      expect(create(:message)).to be_valid
    end
  end

  describe "Database table" do
    it { is_expected.to have_db_column :conversation_id }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :body }
    it { is_expected.to have_db_column :created_at }
    it { is_expected.to have_db_column :updated_at }
  end

  describe "Validations" do
    it { is_expected.to validate_length_of(:body).is_at_most(1000) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to have_one(:image_attachment) }
  end

  describe "Attached image" do
    it "is valid" do
      subject.image.attach(
        io: File.open("spec/fixtures/greece.jpg"),
        filename: "attachment.jpg",
        content_type: "image/jpg"
      )
      expect(subject.image).to be_attached
    end
  end
end
