RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe Message, type: :model do
  it 'should have a valid Factory' do
    expect(create(:message)).to be_valid
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :conversation_id }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :body }
  end

  describe 'Validations' do
    it { is_expected.to validate_length_of :body }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to have_one(:image_attachment) }
  end

  describe 'Attached image' do
    it 'is valid' do
      subject.image.attach(
        io: File.open('spec/fixtures/greece.jpg'),
        filename: 'attachment.jpg',
        content_type: 'image/jpg'
      )
      expect(subject.image).to be_attached
    end
  end

  describe 'Delete dependent setting' do
    it 'message is deleted when associated conversation is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@cyprus.com', nickname: 'george')
      user2 = FactoryBot.create(:user, email: 'zane@sweden.com', nickname: 'zane')
      FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id)
      FactoryBot.create(:message, conversation_id: Conversation.last.id, user_id: user1.id)
      expect(User.all.length).to eq 2
      expect(Conversation.all.length).to eq 1
      expect(Message.all.length).to eq 1
      Conversation.last.destroy
      expect(User.all.length).to eq 2
      expect(Conversation.all.length).to eq 0
      expect(Message.all.length).to eq 0
    end

    it 'performance stats for conversation deletion with associated message' do
      user1 = FactoryBot.create(:user, email: 'george@cyprus.com', nickname: 'george')
      user2 = FactoryBot.create(:user, email: 'zane@sweden.com', nickname: 'zane')
      conversation = FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id)
      FactoryBot.create(:message, conversation_id: conversation.id, user_id: user1.id)
      expect { conversation.destroy }.to perform_under(100).ms.sample(20).times
      expect { conversation.destroy }.to perform_at_least(1000).ips
    end

    it 'user association of message is nullified when associated user is deleted from the database' do
      user1 = FactoryBot.create(:user, email: 'george@cyprus.com', nickname: 'george')
      user2 = FactoryBot.create(:user, email: 'zane@sweden.com', nickname: 'zane')
      FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id)
      FactoryBot.create(:message, user_id: user1.id, conversation_id: Conversation.last.id)
      expect(User.all.length).to eq 2
      expect(Conversation.all.length).to eq 1
      expect(Message.all.length).to eq 1
      user1.destroy
      expect(User.all.length).to eq 1
      expect(Conversation.all.length).to eq 1
      expect(Message.all.length).to eq 1
      expect(Message.last.user_id).to eq nil
    end

    it 'performance stats for user deletion and nullification of associated message' do
      user1 = FactoryBot.create(:user, email: 'george@cyprus.com', nickname: 'george')
      user2 = FactoryBot.create(:user, email: 'zane@sweden.com', nickname: 'zane')
      FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id)
      FactoryBot.create(:message, user_id: user1.id, conversation_id: Conversation.last.id)
      expect { user1.destroy }.to perform_under(150).ms.sample(20).times
      expect { user1.destroy }.to perform_at_least(150).ips
    end
  end
end
