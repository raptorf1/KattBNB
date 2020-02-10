RSpec.describe MessagesMailer, type: :mailer do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let(:message) { FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation.id, body: 'Something') }
  let(:message2) { FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation.id, body: 'SomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomething') }
  let(:new_message_mail) { MessagesMailer.notify_user_new_message(user1, user2, message.body) }
  let(:new_message_mail2) { MessagesMailer.notify_user_new_message(user1, user2, message2.body) }

  describe 'notify_user_new_message' do
    it 'renders the subject' do
      expect(new_message_mail.subject).to eql("New message from #{user1.nickname}!")
    end

    it 'renders the receiver email' do
      expect(new_message_mail.to).to eql([user2.email])
    end

    it 'renders the sender email' do
      expect(new_message_mail.from).to eql('KattBNB Notification Service')
    end

    it "contains users' nicknames" do
      expect(new_message_mail.body.encoded).to match("Hey #{user2.nickname}!")
      expect(new_message_mail.body.encoded).to match("#{user1.nickname}")
      expect(new_message_mail.body.encoded).to match("#{message.body}")
      expect(new_message_mail2.body.encoded).to match('SomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingS...')
    end
  end
end
