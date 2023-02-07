RSpec.describe ReportsMailer, type: :mailer do
  let(:booking) { FactoryBot.create(:booking) }
  let(:new_report_mail) { ReportsMailer.bookings_revenue_and_vat(booking) }

  describe "bookings_revenue_and_vat" do
    it "renders the subject" do
      expect(new_report_mail.subject).to eql("New paid booking with id #{booking.id}")
    end

    it "renders the receiver email" do
      expect(new_report_mail.to).to eql(["raptor_f1@hotmail.com"])
    end

    it "renders the sender email" do
      expect(new_report_mail.from).to eql("KattBNB meow-reply")
    end

    it "contains booking information required" do
      expect(new_report_mail.body.encoded).to match(
        "Please update the spreadsheet with the information below"
      ).and match("Host nickname: #{booking.host_nickname}").and match(
                    "Booking length: #{booking.dates.length}"
                  ).and match("Host got paid: #{booking.price_total}")
    end
  end
end
