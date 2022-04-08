describe 'rake reviews:notify_pending_review', type: :task do
  now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
  now_epoch_javascript = (now.to_f * 1000).to_i
  let(:host) { FactoryBot.create(:user) }
  let(:second_host) { FactoryBot.create(:user) }

  let!(:booking_1_day) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000]
    )
  end

  let!(:booking_3_days) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 3]
    )
  end

  let!(:booking_10_days) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 10]
    )
  end

  let!(:booking_15_days) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 15]
    )
  end

  let(:reviewed_booking) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      host_nickname: second_host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 3]
    )
  end

  let!(:review) { FactoryBot.create(:review, booking_id: reviewed_booking.id) }

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully' do
    before { @subject = task.execute }

    it 'sends correct number of emails to the user' do
      expect(Delayed::Job.all.count).to eq 3
    end

    it 'excludes 15 days old booking' do
      Delayed::Job.all.each { |email| expect(email.handler[(now_epoch_javascript - 86_400_000 * 15).to_s]).to eq nil }
    end

    it 'runs with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'excludes already reviewed booking' do
      Delayed::Job.all.each { |email| expect(email.handler[second_host.nickname.to_s]).to eq nil }
    end

    it 'logs to stdout' do
      expect(@std_output).to eq(
        "User #{booking_1_day.user.nickname} notified to leave review after 1 day for booking with id #{booking_1_day.id}!User #{booking_3_days.user.nickname} notified to leave review after 3 days for booking with id #{booking_3_days.id}!User #{booking_10_days.user.nickname} notified to leave review after 10 days for booking with id #{booking_10_days.id}!"
      )
    end
  end

  describe 'unsuccessfully' do
    before do
      booking_1_day.update(host_nickname: 'Deleted user')
      booking_3_days.update(host_nickname: 'Deleted user')
      booking_10_days.update(host_nickname: 'Deleted user')
      @subject = task.execute
    end

    it 'sends no emails' do
      expect(Delayed::Job.all.count).to eq 0
    end

    it 'logs to stdout' do
      expect(@std_output).to eq(
        'User or host is deleted. Sending notification mail aborted!User or host is deleted. Sending notification mail aborted!User or host is deleted. Sending notification mail aborted!'
      )
    end
  end
end
