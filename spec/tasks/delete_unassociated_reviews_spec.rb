RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

describe 'rake reviews:delete_unassociated_reviews', type: :task do
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:profile) { FactoryBot.create(:host_profile, user_id: host.id) }
  let!(:booking) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname) }
  let!(:review) { FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking.id) }
  let!(:booking2) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname) }
  let!(:review2) { FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking2.id) }
  let!(:booking3) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname) }
  let!(:review3) { FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking3.id) }
  let!(:booking4) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname) }
  let!(:review4) { FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking4.id) }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'logs to stdout' do
    review.update_attribute(:user_id, nil)
    review.update_attribute(:booking_id, nil)
    review.update_attribute(:host_profile_id, nil)
    review2.update_attribute(:user_id, nil)
    review2.update_attribute(:booking_id, nil)
    review2.update_attribute(:host_profile_id, nil)
    expect { task.execute }.to output("2 unassociated review(s) successfully deleted!\n").to_stdout
  end

  it 'performs under 50 ms' do
    expect { task.execute }.to perform_under(50).ms.sample(20).times
  end

  it 'performs at least 500 iterations per second' do
    expect { task.execute }.to perform_at_least(500).ips
  end

end
