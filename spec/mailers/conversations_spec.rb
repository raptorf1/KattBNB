RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe ConversationsMailer, type: :mailer do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let(:user3) { FactoryBot.create(:user, email: 'chaoss@thestreets.com', nickname: 'Joker SV', lang_pref: 'sv-SE') }
  let(:user4) { FactoryBot.create(:user, email: 'orderr@thestreets.com', nickname: 'Batman SV', lang_pref: 'sv-SE') }
  let(:conversatio2) { FactoryBot.create(:conversation, user1_id: user3.id, user2_id: user4.id) }
  let(:new_conversation_mail) { ConversationsMailer.notify_user_new_conversation(user1, user2) }
  let(:new_conversation_mail2) { ConversationsMailer.notify_user_new_conversation(user3, user4) }

  describe 'notify_user_new_conversation' do
    it 'renders the subject' do
      expect(new_conversation_mail.subject).to eql("#{user1.nickname} started a conversation with you!")
    end

    it 'renders the receiver email' do
      expect(new_conversation_mail.to).to eql([user2.email])
    end

    it 'renders the sender email' do
      expect(new_conversation_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains users' nicknames in ENG" do
      expect(new_conversation_mail.body.encoded).to match("Hey, #{user2.nickname}!")
      expect(new_conversation_mail.body.encoded).to match("#{user1.nickname}")
    end

    it "contains users' nicknames in SV" do
      expect(new_conversation_mail2.body.encoded).to match("Hallå, #{user4.nickname}!")
    end

    it 'is performed under 1000ms' do
      expect { new_conversation_mail }.to perform_under(1000).ms.sample(20).times
      expect { new_conversation_mail2 }.to perform_under(1000).ms.sample(20).times
    end

    it 'performs at least 500K iterations per second' do
      expect { new_conversation_mail }.to perform_at_least(500_000).ips
      expect { new_conversation_mail2 }.to perform_at_least(500_000).ips
    end
  end
end
