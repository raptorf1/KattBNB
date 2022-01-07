describe 'rake bookings:cancel_after_3_days', type: :task do
  let!(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:booking) do
    FactoryBot.create(
      :booking,
      created_at: 'Sat, 09 Nov 2019 09:06:48 UTC +00:00',
      user_id: user.id,
      host_nickname: host.nickname,
      dates: [123, 456]
    )
  end
  let!(:booking2) do
    FactoryBot.create(:booking, created_at: Time.current, user_id: user.id, host_nickname: host.nickname)
  end

  it 'emails the user, the host and KattBNB to cancel payment' do
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
    expect { task.execute }.to output("1 pending booking(s) succesfully cancelled!\n").to_stdout
    booking.reload
    booking2.reload
    expect(booking.status).to eq 'canceled'
    expect(booking2.status).to eq 'pending'
  end
end
