namespace :users do
  desc "Deletes all unconfirmed users after 24 hrs"
  task delete_unconfirmed_users: :environment do
    unconfirmed_users = User.where(confirmed_at: nil)
    if !unconfirmed_users.empty?
      unconfirmed_users.each do |user|
        if ((Time.current - user.created_at) / 1.hour).round > 24
          print "Unconfirmed user with name #{user.nickname} and email #{user.email} succesfully deleted!"
          user.destroy
        end
      end
    end
  end

  desc "Deletes all hosts that have not logged in for a year"
  task delete_inactive_hosts_after_1_year: :environment do
    profiles_of_hosts_to_delete =
      HostProfile.joins(:user).where(users: { last_sign_in_at: 5.years.ago..1.year.ago }).select("user_id")
    if !profiles_of_hosts_to_delete.empty?
      profiles_of_hosts_to_delete.each do |profile|
        host = User.find(profile.user_id)
        print "Inactive for 1 year host from #{host.location} with name #{host.nickname} and email #{host.email} succesfully deleted!"
        host.destroy
      end
    end
  end
end
