RSpec.describe BookingsMailer, type: :mailer do
  describe 'notify_host_create_booking' do
    let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
    let(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
    let(:booking) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname) }
    let(:mail) { BookingsMailer.notify_host_create_booking(host, booking, user) }

    it 'renders the subject' do
      expect(mail.subject).to eql('You have a new booking request!')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([host.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql('KattBNB Notification Service')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(mail.body.encoded).to match("Hey #{host.nickname}!")
      expect(mail.body.encoded).to match("#{booking.message}")
      expect(mail.body.encoded).to match("#{user.nickname}")
      expect(mail.body.encoded).to match("#{booking.number_of_cats}")
    end

  end
end
