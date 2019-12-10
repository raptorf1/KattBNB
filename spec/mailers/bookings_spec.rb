RSpec.describe BookingsMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:booking) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname) }
  let(:new_request_mail) { BookingsMailer.notify_host_create_booking(host, booking, user) }
  let(:accepted_request_mail) { BookingsMailer.notify_user_accepted_booking(host, booking, user) }
  let(:declined_request_mail) { BookingsMailer.notify_user_declined_booking(host, booking, user) }


  describe 'notify_host_create_booking' do
    it 'renders the subject' do
      expect(new_request_mail.subject).to eql('You have a new booking request!')
    end

    it 'renders the receiver email' do
      expect(new_request_mail.to).to eql([host.email])
    end

    it 'renders the sender email' do
      expect(new_request_mail.from).to eql('KattBNB Notification Service')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(new_request_mail.body.encoded).to match("Hey #{host.nickname}!")
      expect(new_request_mail.body.encoded).to match("#{booking.message}")
      expect(new_request_mail.body.encoded).to match("#{user.nickname}")
      expect(new_request_mail.body.encoded).to match("#{booking.number_of_cats}")
    end
  end

  describe 'notify_user_accepted_booking' do
    it 'renders the subject' do
      expect(accepted_request_mail.subject).to eql('Your booking request got approved!')
    end

    it 'renders the receiver email' do
      expect(accepted_request_mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(accepted_request_mail.from).to eql('KattBNB Notification Service')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(accepted_request_mail.body.encoded).to match("Hey #{user.nickname}!")
      expect(accepted_request_mail.body.encoded).to match("#{host.nickname}")
      expect(accepted_request_mail.body.encoded).to match("#{booking.number_of_cats}")
    end
  end

  describe 'notify_user_declined_booking' do
    it 'renders the subject' do
      expect(declined_request_mail.subject).to eql('Your booking request got declined!')
    end

    it 'renders the receiver email' do
      expect(declined_request_mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(declined_request_mail.from).to eql('KattBNB Notification Service')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(declined_request_mail.body.encoded).to match("Hey #{user.nickname}!")
      expect(declined_request_mail.body.encoded).to match("#{host.nickname}")
      expect(declined_request_mail.body.encoded).to match("#{booking.number_of_cats}")
      expect(declined_request_mail.body.encoded).to match("#{booking.host_message}")
    end
  end
end
