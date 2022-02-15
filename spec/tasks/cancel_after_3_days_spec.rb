describe 'rake bookings:cancel_after_3_days', type: :task do
  let(:user) { FactoryBot.create(:user) }
  let(:host) { FactoryBot.create(:user) }

  let!(:cancelled_booking) do
    FactoryBot.create(
      :booking,
      created_at: 'Sat, 09 Nov 2019 09:06:48 UTC +00:00',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [123, 456]
    )
  end

  let!(:pending_booking) do
    FactoryBot.create(:booking, created_at: Time.current, user_id: user.id, host_nickname: host.nickname)
  end

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully' do
    before do
      @subject = task.execute
      cancelled_booking.reload
      pending_booking.reload
    end

    it 'logs to stdout' do
      expect(@std_output).to eq("1 pending booking(s) succesfully cancelled!\n")
    end

    it 'changes status of booking to cancelled' do
      expect(cancelled_booking.status).to eq 'canceled'
    end

    it 'does not change status of pending booking' do
      expect(pending_booking.status).to eq 'pending'
    end

    it 'emails the user, the host and KattBNB to cancel payment' do
      expect(Delayed::Job.all.count).to eq 3
    end

    it 'runs with no errors' do
      expect { @subject }.not_to raise_error
    end
  end
end
