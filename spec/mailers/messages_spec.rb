RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe MessagesMailer, type: :mailer do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let(:user3) { FactoryBot.create(:user, email: 'chaoss@thestreets.com', nickname: 'Joker SV') }
  let(:user4) { FactoryBot.create(:user, email: 'orderr@thestreets.com', nickname: 'Batman SV', lang_pref: 'sv-SE') }
  let(:conversation2) { FactoryBot.create(:conversation, user1_id: user3.id, user2_id: user4.id) }
  let(:message) { FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation.id, body: 'Something') }
  let(:message2) { FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation.id, body: 'SomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomething') }
  let(:message3) { FactoryBot.create(:message, user_id: user3.id, conversation_id: conversation2.id, body: 'Something') }
  let(:new_message_mail) { MessagesMailer.notify_user_new_message(user1, user2, message.body) }
  let(:new_message_mail2) { MessagesMailer.notify_user_new_message(user1, user2, message2.body) }
  let(:new_message_mail3) { MessagesMailer.notify_user_new_message(user3, user4, message3.body) }

  describe 'notify_user_new_message' do
    it 'renders the subject' do
      expect(new_message_mail.subject).to eql("New message from #{user1.nickname}!")
    end

    it 'renders the receiver email' do
      expect(new_message_mail.to).to eql([user2.email])
    end

    it 'renders the sender email' do
      expect(new_message_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains users' nicknames in ENG" do
      expect(new_message_mail.body.encoded).to match("Hey, #{user2.nickname}!")
      expect(new_message_mail.body.encoded).to match("#{user1.nickname}")
      expect(new_message_mail.body.encoded).to match("#{message.body}")
      expect(new_message_mail2.body.encoded).to match('SomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingS...')
    end

    it "contains users' nicknames in SV" do
      expect(new_message_mail3.body.encoded).to match("Hallå, #{user4.nickname}!")
    end

    it 'is performed under 500ms' do
      expect { new_message_mail }.to perform_under(500).ms.sample(20).times
      expect { new_message_mail2 }.to perform_under(500).ms.sample(20).times
      expect { new_message_mail3 }.to perform_under(500).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { new_message_mail }.to perform_at_least(800000).ips
      expect { new_message_mail2 }.to perform_at_least(800000).ips
      expect { new_message_mail3 }.to perform_at_least(800000).ips
    end
  end
end
