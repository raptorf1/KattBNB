namespace :users do
  desc 'Deletes all unconfirmed users after 24 hrs'
  task delete_unconfirmed_users: :environment do
    User
      .where(confirmed_at: nil)
      .each do |user|
        if ((Time.current - user.created_at) / 1.hour).round > 24
          puts "Unconfirmed user with name #{user.nickname} and email #{user.email} succesfully deleted!"
          user.destroy
        end
      end
  end
end
