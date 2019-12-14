namespace :users do
  desc 'Deletes all unconfirmed users after 24 hrs'
  task delete_unconfirmed_users: :environment do
    unconfirmed_users = User.where(confirmed_at: nil)
    deleted_users = []
    unconfirmed_users.each do |user|
      if ((Time.current - user.created_at)/1.hour).round > 24
        deleted_users.push(user)
        user.destroy
      end
    end
    puts "#{deleted_users.length} user(s) succesfully deleted!"
  end
end
