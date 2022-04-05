RSpec.describe BookingsMailer, type: :mailer do
  let(:host) { FactoryBot.create(:user) }
  let(:booking) { FactoryBot.create(:booking, host_nickname: host.nickname) }
  let(:new_request_mail) { BookingsMailer.notify_host_create_booking(host, booking, booking.user) }
  let(:accepted_request_mail) { BookingsMailer.notify_user_accepted_booking(host, booking, booking.user) }
  let(:declined_request_mail) { BookingsMailer.notify_user_declined_booking(host, booking, booking.user) }
  let(:cancelled_request_user_mail) { BookingsMailer.notify_user_cancelled_booking(host, booking, booking.user) }
  let(:cancelled_request_host_mail) { BookingsMailer.notify_host_cancelled_booking(host, booking, booking.user) }

  describe 'notify_host_create_booking' do
    before { User.destroy_all }

    it 'renders the subject' do
      expect(new_request_mail.subject).to eql('You have a new booking request!')
    end

    it 'renders the receiver email' do
      expect(new_request_mail.to).to eql([host.email])
    end

    it 'renders the sender email' do
      expect(new_request_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(new_request_mail.body.encoded).to match("Hey, #{host.nickname}!").and match(
                                            "#{booking.message}"
                                          ).and match("#{booking.user.nickname}").and match("#{booking.number_of_cats}")
    end
  end

  describe 'notify_user_accepted_booking' do
    it 'renders the subject' do
      expect(accepted_request_mail.subject).to eql('Your booking request got approved!')
    end

    it 'renders the receiver email' do
      expect(accepted_request_mail.to).to eql([booking.user.email])
    end

    it 'renders the sender email' do
      expect(accepted_request_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(accepted_request_mail.body.encoded).to match("Hey, #{booking.user.nickname}!").and match(
                                                    "#{host.nickname}"
                                                  ).and match("#{booking.number_of_cats}")
    end

    it 'contains 2 calendar events as attachments' do
      expect(accepted_request_mail.body.parts[1].content_disposition).to eql(
        'attachment; filename=AddToMyCalendarDropOff.ics'
      )
      expect(accepted_request_mail.body.parts[2].content_disposition).to eql(
        'attachment; filename=AddToMyCalendarPickUp.ics'
      )
    end
  end

  describe 'notify_user_declined_booking' do
    it 'renders the subject' do
      expect(declined_request_mail.subject).to eql('Your booking request got declined!')
    end

    it 'renders the receiver email' do
      expect(declined_request_mail.to).to eql([booking.user.email])
    end

    it 'renders the sender email' do
      expect(declined_request_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(declined_request_mail.body.encoded).to match("Hey, #{booking.user.nickname}!").and match(
                                                    "#{host.nickname}"
                                                  ).and match("#{booking.number_of_cats}").and match(
                                                                                                                         "#{booking.host_message}"
                                                                                                                       )
    end
  end

  describe 'notify_user_cancelled_booking' do
    it 'renders the subject' do
      expect(cancelled_request_user_mail.subject).to eql('Your booking request got cancelled!')
    end

    it 'renders the receiver email' do
      expect(cancelled_request_user_mail.to).to eql([booking.user.email])
    end

    it 'renders the sender email' do
      expect(cancelled_request_user_mail.from).to eql('KattBNB meow-reply')
    end

    it "contains basic booking information and host's & user's nicknames" do
      expect(cancelled_request_user_mail.body.encoded).to match("Hey, #{booking.user.nickname}!").and match(
                                                    "#{host.nickname}"
                                                  ).and match("#{booking.number_of_cats}")
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
      expect(cancelled_request_host_mail.body.encoded).to match("Hey, #{host.nickname}!").and match(
                                            "#{booking.user.nickname}"
                                          ).and match("#{booking.number_of_cats}")
    end
  end
end
