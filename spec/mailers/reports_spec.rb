RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe ReportsMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:booking) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, dates: [1,2,3,4,5,6,7,8,9], price_total: 1550.06) }
  let(:new_report_mail) { ReportsMailer.bookings_revenue_and_vat(booking) }

  describe 'bookings_revenue_and_vat' do
    it 'renders the subject' do
      expect(new_report_mail.subject).to eql("New paid booking with id #{booking.id}")
    end

    it 'renders the receiver email' do
      expect(new_report_mail.to).to eql(['george@kattbnb.se'])
    end

    it 'renders the sender email' do
      expect(new_report_mail.from).to eql('KattBNB meow-reply')
    end

    it 'contains booking information required' do
      expect(new_report_mail.body.encoded).to match('Please update the spreadsheet with the information below')
      expect(new_report_mail.body.encoded).to match("Host nickname: #{host.nickname}")
      expect(new_report_mail.body.encoded).to match("Booking length: #{booking.dates.length}")
      expect(new_report_mail.body.encoded).to match("Host got paid: #{booking.price_total}")
    end

    it 'is performed under 500ms' do
      expect { new_report_mail }.to perform_under(500).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { new_report_mail }.to perform_at_least(800000).ips
    end
  end

end
