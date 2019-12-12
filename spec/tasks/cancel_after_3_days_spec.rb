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

  # it "emails invoices" do
  #   subscriber = create(:subscriber)

  #   task.execute

  #   expect(subscriber).to have_received_invoice
  # end

  # it "checks in with Dead Mans Snitch" do
  #   dead_mans_snitch_request = stub_request(:get, "https://nosnch.in/c2354d53d2")

  #   task.execute

  #   expect(dead_mans_snitch_request).to have_been_requested
  # end

  # matcher :have_received_invoice do
  #   match_unless_raises do |subscriber|
  #     expect(last_email_sent).to be_delivered_to subscriber.email
  #     expect(last_email_sent).to have_subject 'Your invoice'
  #     ...
  #   end
  # end

end
