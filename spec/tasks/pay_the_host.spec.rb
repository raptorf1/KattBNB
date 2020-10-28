RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

describe 'rake bookings:pay_the_host', type: :task do
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:profile) { FactoryBot.create(:host_profile, user_id: host.id, stripe_account_id: 'acct_1HSQspCYqtPdaLmE') }
  let!(:booking) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'accepted', dates: [123, 456], paid: false, price_total: 1.0) }
  let!(:booking2) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'accepted', dates: [123, 456, 9563148800000], paid: false) }
  let!(:booking3) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'pending', paid: false) }
  let!(:booking4) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'declined', paid: false) }
  let!(:booking5) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'canceled', paid: false) }
  let!(:booking6) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'accepted', dates: [123, 456], paid: true) }

  it 'emails the user, the host and KattBNB to cancel payment' do
    task.execute
    booking.reload
    expect(booking.paid).to eq true
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'performs under 30 ms' do
    expect { task.execute }.to perform_under(30).ms.sample(20).times
  end

  it 'performs at least 500 iterations per second' do
    expect { task.execute }.to perform_at_least(500).ips
  end

end
