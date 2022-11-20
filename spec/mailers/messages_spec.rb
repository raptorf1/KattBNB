RSpec.describe MessagesMailer, type: :mailer do
  let(:message) do
    FactoryBot.create(:message, body: "Something" * 20, created_at: "Wed, 29 Apr 2020 20:27:22 UTC +00:00")
  end
  let(:new_message_mail) do
    MessagesMailer.notify_user_new_message(message.user, message.conversation.user2, message.body, message.created_at)
  end

  describe "notify_user_new_message" do
    it "renders the subject" do
      expect(new_message_mail.subject).to eql("New message from #{message.user.nickname}!")
    end

    it "renders the receiver email" do
      expect(new_message_mail.to).to eql([message.conversation.user2.email])
    end

    it "renders the sender email" do
      expect(new_message_mail.from).to eql("KattBNB meow-reply")
    end

    it "contains users' nicknames" do
      expect(new_message_mail.body.encoded).to match("Hey, #{message.conversation.user2.nickname}!").and match(
              "#{message.user.nickname}"
            ).and match(
                    "SomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingSomethingS..."
                  )
    end
  end
end
