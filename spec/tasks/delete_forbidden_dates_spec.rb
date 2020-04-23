RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

describe 'rake profiles:delete_forbidden_dates', type: :task do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:user3) { FactoryBot.create(:user, email: 'fun@thestreets.com', nickname: 'Harley Qween') }
  let!(:profile1) { FactoryBot.create(:host_profile, user_id: user1.id, forbidden_dates: [1362803200000, 1362889600000, 1362976000000, 1363062400000, 2363148800000]) }
  let!(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id, forbidden_dates: [2562803200000, 2562889600000, 2562976000000, 2563062400000, 2563148800000]) }
  let!(:profile3) { FactoryBot.create(:host_profile, user_id: user3.id, forbidden_dates: []) }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'updates targeted host profile' do
    task.execute
    profile1.reload
    profile2.reload
    profile3.reload
    expect(profile1.forbidden_dates).to eq [2363148800000]
    expect(profile2.forbidden_dates).to eq [2562803200000, 2562889600000, 2562976000000, 2563062400000, 2563148800000]
    expect(profile3.forbidden_dates).to eq []
  end

  it 'logs to stdout' do
    expect { task.execute }.to output("Forbidden dates of 1 host profile(s) succesfully updated!\n").to_stdout
  end

  it 'performs under 30 ms' do
    expect { task.execute }.to perform_under(30).ms.sample(20).times
  end

  it 'performs at least 500 iterations per second' do
    expect { task.execute }.to perform_at_least(500).ips
  end

end
