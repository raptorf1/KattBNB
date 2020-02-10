RSpec.describe ConversationsMailer, type: :mailer do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let(:new_conversation_mail) { ConversationsMailer.notify_user_new_conversation(user1, user2) }

  describe 'notify_user_new_conversation' do
    it 'renders the subject' do
      expect(new_conversation_mail.subject).to eql("#{user1.nickname} started a conversation with you!")
    end

    it 'renders the receiver email' do
      expect(new_conversation_mail.to).to eql([user2.email])
    end

    it 'renders the sender email' do
      expect(new_conversation_mail.from).to eql('KattBNB Notification Service')
    end

    it "contains users' nicknames" do
      expect(new_conversation_mail.body.encoded).to match("Hey #{user2.nickname}!")
      expect(new_conversation_mail.body.encoded).to match("#{user1.nickname}")
    end
  end
end
