describe 'rake bookings:cancel_after_3_days', type: :task do
  let!(:booking) { FactoryBot.create(:booking, created_at: 'Sat, 09 Nov 2019 09:06:48 UTC +00:00' )}

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'logs to stdout' do
    expect { task.execute }.to output("1 pending booking(s) succesfully cancelled!\n").to_stdout
  end

  it 'emails the user and the host' do
    task.execute
    expect(ActionMailer::Base.deliveries.count).to eq 2
  end
end
