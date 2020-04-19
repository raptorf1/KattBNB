RSpec.describe BookingsMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:user2) { FactoryBot.create(:user, email: 'chaos2@thestreets.com', nickname: 'SV Joker', lang_pref: 'sv-SE') }
  let(:host2) { FactoryBot.create(:user, email: 'order2@thestreets.com', nickname: 'SV Batman', lang_pref: 'sv-SE') }
  let(:booking) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname) }
  let(:booking2) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, price_total: '1550') }
  let(:booking3) { FactoryBot.create(:booking, user_id: user2.id, host_nickname: host2.nickname) }
  let(:new_request_mail) { BookingsMailer.notify_host_create_booking(host, booking, user) }
  let(:new_request_mail2) { BookingsMailer.notify_host_create_booking(host2, booking3, user2) }
  let(:accepted_request_mail) { BookingsMailer.notify_user_accepted_booking(host, booking, user) }
  let(:declined_request_mail) { BookingsMailer.notify_user_declined_booking(host, booking, user) }
  let(:cancelled_request_user_mail) { BookingsMailer.notify_user_cancelled_booking(host, booking, user) }
  let(:cancelled_request_host_mail) { BookingsMailer.notify_host_cancelled_booking(host, booking, user) }
  let(:on_delete_account_host_mail) { BookingsMailer.notify_host_on_user_account_deletion(host, booking, user) }
  let(:on_delete_account_host_mail2) { BookingsMailer.notify_host_on_user_account_deletion(host, booking2, user) }

  describe 'notify_host_create_booking' do
    it 'renders the subject' do
      expect(new_request_mail.subject).to eql('You have a new booking request!')
    end

    it 'renders the receiver email' do
      expect(new_request_mail.to).to eql([host.email])
    end

    it 'renders the sender email' do
      expect(new_request_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames in ENG" do
      expect(new_request_mail.body.encoded).to match("Hey, #{host.nickname}!")
      expect(new_request_mail.body.encoded).to match("#{booking.message}")
      expect(new_request_mail.body.encoded).to match("#{user.nickname}")
      expect(new_request_mail.body.encoded).to match("#{booking.number_of_cats}")
    end

    it "contains basic booking information and host's nickname in SV" do
      expect(new_request_mail2.body.encoded).to match("Hallå, #{host2.nickname}!")
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
      expect(accepted_request_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(accepted_request_mail.body.encoded).to match("Hey, #{user.nickname}!")
      expect(accepted_request_mail.body.encoded).to match("#{host.nickname}")
      expect(accepted_request_mail.body.encoded).to match("#{booking.number_of_cats}")
    end

    it 'contains 2 calendar events as attachments' do
      expect(accepted_request_mail.body.parts[1].content_disposition).to eql('attachment; filename=booking_drop_off.ics')
      expect(accepted_request_mail.body.parts[2].content_disposition).to eql('attachment; filename=booking_collect.ics')
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
      expect(declined_request_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(declined_request_mail.body.encoded).to match("Hey, #{user.nickname}!")
      expect(declined_request_mail.body.encoded).to match("#{host.nickname}")
      expect(declined_request_mail.body.encoded).to match("#{booking.number_of_cats}")
      expect(declined_request_mail.body.encoded).to match("#{booking.host_message}")
    end
  end

  describe 'notify_user_cancelled_booking' do
    it 'renders the subject' do
      expect(cancelled_request_user_mail.subject).to eql('Your booking request got cancelled!')
    end

    it 'renders the receiver email' do
      expect(cancelled_request_user_mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(cancelled_request_user_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(cancelled_request_user_mail.body.encoded).to match("Hey, #{user.nickname}!")
      expect(cancelled_request_user_mail.encoded).to match("#{host.nickname}")
      expect(cancelled_request_user_mail.encoded).to match("#{booking.number_of_cats}")
    end
  end

  describe 'notify_host_cancelled_booking' do
    it 'renders the subject' do
      expect(cancelled_request_host_mail.subject).to eql('Cancelled booking request!')
    end

    it 'renders the receiver email' do
      expect(cancelled_request_host_mail.to).to eql([host.email])
    end

    it 'renders the sender email' do
      expect(cancelled_request_host_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(cancelled_request_host_mail.body.encoded).to match("Hey, #{host.nickname}!")
      expect(cancelled_request_host_mail.encoded).to match("#{user.nickname}")
      expect(cancelled_request_host_mail.encoded).to match("#{booking.number_of_cats}")
    end
  end

  describe 'notify_host_on_user_account_deletion' do
    it 'renders the subject' do
      expect(on_delete_account_host_mail.subject).to eql('Important information about your upcoming booking!')
    end

    it 'renders the receiver email' do
      expect(on_delete_account_host_mail.to).to eql([host.email])
    end

    it 'renders the sender email' do
      expect(on_delete_account_host_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(on_delete_account_host_mail.body.encoded).to match("Hey, #{host.nickname}!")
      expect(on_delete_account_host_mail.encoded).to match("#{user.nickname}")
      expect(on_delete_account_host_mail.encoded).to match("#{booking.number_of_cats}")
      expect(on_delete_account_host_mail.encoded).to match('1550.20 kr')
    end

    it 'the 100% spec!' do
      expect(on_delete_account_host_mail2.encoded).to match('1550 kr')
    end
  end
end
