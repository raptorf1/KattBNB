RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

describe 'rake users:delete_unconfirmed_users', type: :task do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', created_at: 'Thu, 07 Nov 2019 09:06:48 UTC +00:00', confirmed_at: nil) }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman', created_at: 'Sat, 09 Nov 2019 09:00:48 UTC +00:00', confirmed_at: 'Sat, 09 Nov 2019 09:06:48 UTC +00:00') }
  let!(:user3) { FactoryBot.create(:user, email: 'cat@woman.com', nickname: 'Catwoman', created_at: Time.current, confirmed_at: nil) }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'deletes only unconfirmed users after 24 hours' do
    expect(User.all.length).to eq 3
    task.execute
    expect(User.all.length).to eq 2
    users = User.all
    expect(users[0].email).to eq 'order@thestreets.com'
    expect(users[1].email).to eq 'cat@woman.com'
  end

  it 'logs to stdout' do
    expect { task.execute }.to output("1 user(s) succesfully deleted!\n").to_stdout
  end

  it 'performs under 30 ms' do
    expect { task.execute }.to perform_under(30).ms.sample(20).times
  end

  it 'performs at least 500 iterations per second' do
    expect { task.execute }.to perform_at_least(500).ips
  end

end
