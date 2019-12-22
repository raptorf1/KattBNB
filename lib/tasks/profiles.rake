namespace :profiles do
  desc 'Delete past dates from forbidden_dates field of host profiles'
  task delete_forbidden_dates: :environment do
    host_profiles = HostProfile.where('array_length(forbidden_dates, 1) > 0')
    changed_profiles = []
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    host_profiles.each do |profile|
      if profile.forbidden_dates[0] < now_epoch_javascript
        profile.update(forbidden_dates: profile.forbidden_dates.select{|date| date > now_epoch_javascript})
        changed_profiles.push(profile)
      end
    end
    puts "Forbidden dates of #{changed_profiles.length} host profile(s) succesfully updated!"
  end
end
