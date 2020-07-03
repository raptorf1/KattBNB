RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

describe 'rake reviews:notify_pending_review', type: :task do
  now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
  now_epoch_javascript = (now.to_f * 1000).to_i
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:booking) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname, dates: [now_epoch_javascript - 86400000]) }
  let!(:booking2) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname, dates: [now_epoch_javascript - 86400000*3]) }
  let!(:booking3) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname, dates: [now_epoch_javascript - 86400000*10]) }
  let!(:booking4) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname, dates: [now_epoch_javascript - 86400000*15]) }

  it 'emails the user and the host' do
    task.execute
    jobs = Delayed::Job.all
    expect(Delayed::Job.all.count).to eq 3
    expect(jobs.first.queue).to eq 'reviews_email_notifications'
    expect(jobs[1].queue).to eq 'reviews_email_notifications'
    expect(jobs.last.queue).to eq 'reviews_email_notifications'
    expect(jobs.first.handler).to match('notify_user_pending_review_1_day')
    expect(jobs[1].handler).to match('notify_user_pending_review_3_days')
    expect(jobs.last.handler).to match('notify_user_pending_review_10_days')
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'logs to stdout' do
    expect { task.execute }.to output("1 user(s) notified to leave review after 1 day!\n1 user(s) notified to leave review after 3 days!\n1 user(s) notified to leave review after 10 days!\n").to_stdout
  end

  it 'performs under 50 ms' do
    expect { task.execute }.to perform_under(50).ms.sample(20).times
  end

  it 'performs at least 5 iterations per second' do
    expect { task.execute }.to perform_at_least(5).ips
  end

end
