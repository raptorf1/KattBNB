namespace :users do
  desc "Deletes all unconfirmed users after 24 hrs"
  task delete_unconfirmed_users: :environment do
    unconfirmed_users = User.where(confirmed_at: nil)
    unconfirmed_users.each do |user|
      if ((Time.current - user.created_at) / 1.hour).round > 24
        print "Unconfirmed user with name #{user.nickname} and email #{user.email} succesfully deleted!"
        user.destroy
      end
    end
  end

  desc "Deletes all hosts that have not logged in for a year"
  task delete_inactive_hosts_after_1_year: :environment do
    all_host_profiles = HostProfile.all
    all_host_profiles.each do |profile|
      host = profile.user
      if ((Time.current - host.last_sign_in_at) / 1.year) >= 1
        print "Inactive for 1 year host with name #{host.nickname}, email #{host.email} and host profile id #{profile.id} succesfully deleted!"
        host.destroy
      end
    end
  end
end
