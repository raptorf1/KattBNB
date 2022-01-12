describe 'rake reviews:notify_pending_review', type: :task do
  now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
  now_epoch_javascript = (now.to_f * 1000).to_i

  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }

  let!(:booking_1_day) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000]
    )
  end

  let!(:booking_3_days) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 3]
    )
  end

  let!(:booking_10_days) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 10]
    )
  end

  let!(:booking_15_days) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 15]
    )
  end

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

    it 'runs gracefully with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'logs to stdout' do
      expect(@std_output).to eq(
        "1 user(s) notified to leave review after 1 day!\n1 user(s) notified to leave review after 3 days!\n1 user(s) notified to leave review after 10 days!\n"
      )
    end
  end
end
