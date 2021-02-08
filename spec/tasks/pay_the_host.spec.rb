RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

# happy path
describe 'rake bookings:pay_the_host', type: :task do
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:profile) { FactoryBot.create(:host_profile, user_id: host.id, stripe_account_id: 'acct_1Hywpk2HucmOr4dd') }
  let!(:unpaid_accepted_booking_past) do
    FactoryBot.create(
      :booking,
      user_id: user.id,
      host_nickname: host.nickname,
      status: 'accepted',
      dates: [123, 456],
      paid: false,
      price_total: 1.0
    )
  end
  let!(:unpaid_accepted_booking_future) do
    FactoryBot.create(
      :booking,
      user_id: user.id,
      host_nickname: host.nickname,
      status: 'accepted',
      dates: [123, 456, 9_563_148_800_000],
      paid: false
    )
  end
  let!(:pending_booking) do
    FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'pending', paid: false)
  end
  let!(:declined_booking) do
    FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'declined', paid: false)
  end
  let!(:canceled_booking) do
    FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname, status: 'canceled', paid: false)
  end
  let!(:paid_accepted_booking) do
    FactoryBot.create(
      :booking,
      user_id: user.id,
      host_nickname: host.nickname,
      status: 'accepted',
      dates: [123, 456],
      paid: true
    )
  end

  it 'pays the host and updates the correct booking' do
    expect(unpaid_accepted_booking_past.paid).to eq false
    expect(unpaid_accepted_booking_future.paid).to eq false
    expect(pending_booking.paid).to eq false
    expect(declined_booking.paid).to eq false
    expect(canceled_booking.paid).to eq false
    expect(paid_accepted_booking.paid).to eq true
    task.execute
    unpaid_accepted_booking_past.reload
    unpaid_accepted_booking_future.reload
    pending_booking.reload
    declined_booking.reload
    canceled_booking.reload
    paid_accepted_booking.reload
    expect(unpaid_accepted_booking_past.paid).to eq true
    expect(unpaid_accepted_booking_future.paid).to eq false
    expect(pending_booking.paid).to eq false
    expect(declined_booking.paid).to eq false
    expect(canceled_booking.paid).to eq false
    expect(paid_accepted_booking.paid).to eq true
  end

  it 'logs to stdout' do
    expect { task.execute }.to output("A report email was sent!\n").to_stdout
  end
end

# sad path
describe 'rake bookings:pay_the_host', type: :task do
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:profile) { FactoryBot.create(:host_profile, user_id: host.id, stripe_account_id: 'acct_1kdhfsjdhfsfkljsd') }
  let!(:booking) do
    FactoryBot.create(
      :booking,
      user_id: user.id,
      host_nickname: host.nickname,
      status: 'accepted',
      dates: [123, 456],
      paid: false,
      price_total: 1.0
    )
  end

  it 'sends email on Stripe error' do
    task.execute
    jobs = Delayed::Job.all
    expect(jobs.count).to eq 1
    expect(jobs[0].queue).to eq 'stripe_email_notifications'
    expect(jobs[0].handler).to match("Payment to host for booking id #{booking.id} failed")
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

  it 'performs at least 1 iteration per second' do
    expect { task.execute }.to perform_at_least(1).ips
  end
end
