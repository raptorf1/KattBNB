RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

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

    it 'is performed under 500ms' do
      expect { new_request_mail }.to perform_under(500).ms.sample(20).times
      expect { new_request_mail2 }.to perform_under(500).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { new_request_mail }.to perform_at_least(800000).ips
      expect { new_request_mail2 }.to perform_at_least(800000).ips
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
      expect(accepted_request_mail.body.parts[1].content_disposition).to eql('attachment; filename=AddToMyCalendarDropOff.ics')
      expect(accepted_request_mail.body.parts[2].content_disposition).to eql('attachment; filename=AddToMyCalendarPickUp.ics')
    end

    it 'is performed under 500ms' do
      expect { accepted_request_mail }.to perform_under(500).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { accepted_request_mail }.to perform_at_least(800000).ips
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

    it 'is performed under 500ms' do
      expect { declined_request_mail }.to perform_under(500).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { declined_request_mail }.to perform_at_least(800000).ips
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

    it 'is performed under 500ms' do
      expect { cancelled_request_user_mail }.to perform_under(500).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { cancelled_request_user_mail }.to perform_at_least(800000).ips
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

    it 'is performed under 500ms' do
      expect { cancelled_request_host_mail }.to perform_under(500).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { cancelled_request_host_mail }.to perform_at_least(800000).ips
    end
  end

end
