describe "rake users:delete_inactive_hosts_after_1_year", type: :task do
  let!(:user) { FactoryBot.create(:user, last_sign_in_at: Time.current - 1.year) }

  let!(:host_to_delete) { FactoryBot.create(:user, last_sign_in_at: Time.current - 12.months) }
  let!(:profile_to_delete) { FactoryBot.create(:host_profile, user_id: host_to_delete.id) }

  let!(:host_to_keep) { FactoryBot.create(:user, last_sign_in_at: Time.current - 11.months) }
  let!(:profile_to_keep) { FactoryBot.create(:host_profile, user_id: host_to_keep.id) }

  it "successfully preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  describe "successfully" do
    before { @subject = task.execute }

    it "runs with no errors" do
      expect { @subject }.not_to raise_error
    end

    it "deletes only inactive host for a year and more" do
      expect(User.all.length).to eq 2
    end

    it "deletes associated host profile" do
      expect(HostProfile.all.length).to eq 1
    end

    it "keeps host below 1 year and users" do
      expect { User.find(host_to_delete.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "keeps host profile of host below 1 year" do
      expect { HostProfile.find(profile_to_delete.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "logs to stdout" do
      expect(@std_output).to eq(
        "Inactive for 1 year host with name #{host_to_delete.nickname} and email #{host_to_delete.email} succesfully deleted!"
      )
    end
  end
end
