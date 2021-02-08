RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

describe 'rake reviews:notify_pending_review', type: :task do
  now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
  now_epoch_javascript = (now.to_f * 1000).to_i
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:booking) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000]
    )
  end
  let!(:booking2) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 3]
    )
  end
  let!(:booking3) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 10]
    )
  end
  let!(:booking4) do
    FactoryBot.create(
      :booking,
      status: 'accepted',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [now_epoch_javascript - 86_400_000 * 15]
    )
  end

  it 'emails the user' do
    task.execute
    expect(Delayed::Job.all.count).to eq 3
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'logs to stdout' do
    expect { task.execute }.to output(
      "1 user(s) notified to leave review after 1 day!\n1 user(s) notified to leave review after 3 days!\n1 user(s) notified to leave review after 10 days!\n"
    ).to_stdout
  end

  it 'performs under 50 ms' do
    expect { task.execute }.to perform_under(50).ms.sample(20).times
  end

  it 'performs at least 5 iterations per second' do
    expect { task.execute }.to perform_at_least(5).ips
  end
end
