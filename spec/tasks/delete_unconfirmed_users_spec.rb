describe 'rake users:delete_unconfirmed_users', type: :task do
  let!(:unconfirmed_user) do
    FactoryBot.create(:user, created_at: 'Thu, 07 Nov 2019 09:06:48 UTC +00:00', confirmed_at: nil)
  end

  let!(:confirmed_user) do
    FactoryBot.create(
      :user,
      created_at: 'Sat, 09 Nov 2019 09:00:48 UTC +00:00',
      confirmed_at: 'Sat, 09 Nov 2019 09:06:48 UTC +00:00'
    )
  end

  let!(:new_user) { FactoryBot.create(:user, created_at: Time.current, confirmed_at: nil) }

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully' do
    before { @subject = task.execute }

    it 'runs with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'deletes only unconfirmed users after 24 hours' do
      expect(User.all.length).to eq 2
    end

    it 'keeps confirmed users and newly created users' do
      expect { User.find(unconfirmed_user.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'logs to stdout' do
      expect(@std_output).to eq(
        "Unconfirmed user with name #{unconfirmed_user.nickname} and email #{unconfirmed_user.email} succesfully deleted!"
      )
    end
  end
end
