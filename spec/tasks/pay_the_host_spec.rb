describe "rake bookings:pay_the_host", type: :task do
  let(:host) { FactoryBot.create(:user) }

  let!(:unpaid_accepted_booking_past) do
    FactoryBot.create(
      :booking,
      host_nickname: host.nickname,
      status: "accepted",
      dates: [123, 456],
      paid: false,
      price_total: 1.0
    )
  end

  let!(:unpaid_accepted_booking_future) do
    FactoryBot.create(
      :booking,
      host_nickname: host.nickname,
      status: "accepted",
      dates: [123, 456, 9_563_148_800_000],
      paid: false
    )
  end

  let!(:paid_accepted_booking) do
    FactoryBot.create(:booking, host_nickname: host.nickname, status: "accepted", dates: [123, 456], paid: true)
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  describe "succesfully" do
    let!(:profile) { FactoryBot.create(:host_profile, user_id: host.id, stripe_account_id: "acct_1Hywpk2HucmOr4dd") }

    before do
      @subject = task.execute
      unpaid_accepted_booking_past.reload
      unpaid_accepted_booking_future.reload
      paid_accepted_booking.reload
    end

    it "runs with no errors" do
      expect { @subject }.not_to raise_error
    end

    it "pays the host and updates the correct booking" do
      expect(unpaid_accepted_booking_past.paid).to eq true
    end

    it "does not pay the host of future booking" do
      expect(unpaid_accepted_booking_future.paid).to eq false
    end

    it "does not pay again the host of an already paid booking" do
      expect(paid_accepted_booking.paid).to eq true
    end

    it "logs to stdout" do
      expect(@std_output).to eq(
        "A report email was sent! Booking with id #{unpaid_accepted_booking_past.id} successfully paid!"
      )
    end
  end

  describe "unsuccessfully" do
    let!(:profile) { FactoryBot.create(:host_profile, user_id: host.id, stripe_account_id: "acct_madeupaccountid") }

    before do
      @subject = task.execute
      unpaid_accepted_booking_past.reload
      unpaid_accepted_booking_future.reload
      paid_accepted_booking.reload
      @jobs = Delayed::Job.all
    end

    it "sends correct number of emails on Stripe error" do
      expect(@jobs.count).to eq 1
    end

    it "sent email has the correct queue name" do
      expect(@jobs.first.queue).to eq "stripe_email_notifications"
    end

    it "sent email has the correct booking ID as subject" do
      expect(@jobs.first.handler).to match("Payment to host for booking id #{unpaid_accepted_booking_past.id} failed")
    end

    it "logs to stdout (stripe error)" do
      expect(@std_output).to match("No such destination:")
    end

    it "does not update an eligible to be paid unpaid booking" do
      expect(unpaid_accepted_booking_past.paid).to eq false
    end

    it "does not update future booking" do
      expect(unpaid_accepted_booking_future.paid).to eq false
    end

    it "does not update an already paid booking" do
      expect(paid_accepted_booking.paid).to eq true
    end
  end
end
