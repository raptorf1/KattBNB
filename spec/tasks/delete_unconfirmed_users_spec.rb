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

  it 'deletes only unconfirmed users after 24 hrs' do
    expect(User.all.length).to eq 3
    task.execute
    expect(User.all.length).to eq 2
  end

  it 'logs to stdout' do
    expect { task.execute }.to output("1 user(s) succesfully deleted!\n").to_stdout
  end
end