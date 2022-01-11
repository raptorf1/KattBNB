describe 'rake users:delete_unconfirmed_users', type: :task do
  let!(:unconfirmed_user) do
    FactoryBot.create(
      :user,
      email: 'chaos@thestreets.com',
      nickname: 'Joker',
      created_at: 'Thu, 07 Nov 2019 09:06:48 UTC +00:00',
      confirmed_at: nil
    )
  end

  let!(:confirmed_user) do
    FactoryBot.create(
      :user,
      email: 'order@thestreets.com',
      nickname: 'Batman',
      created_at: 'Sat, 09 Nov 2019 09:00:48 UTC +00:00',
      confirmed_at: 'Sat, 09 Nov 2019 09:06:48 UTC +00:00'
    )
  end

  let!(:new_user) do
    FactoryBot.create(:user, email: 'cat@woman.com', nickname: 'Catwoman', created_at: Time.current, confirmed_at: nil)
  end

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully' do
    before { @subject = task.execute }

    it 'runs gracefully with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'deletes only unconfirmed users after 24 hours' do
      expect(User.all.length).to eq 2
    end

    it 'keeps confirmed users and newly created users' do
      expect { User.find(unconfirmed_user.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'logs to stdout' do
      expect(@std_output).to eq("1 user(s) succesfully deleted!\n")
    end
  end
end
