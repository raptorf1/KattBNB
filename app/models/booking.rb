class Booking < ApplicationRecord

  before_destroy :actions_per_status
  
  belongs_to :user

  enum status: [:accepted, :pending, :declined, :canceled]

  validates_presence_of :number_of_cats, :message, :dates, :host_nickname, :status, :price_per_day, :price_total, :user_id
  validates :message, length: { maximum: 400 }
  validates :host_message, length: { maximum: 200 }

  def actions_per_status
    host = User.where(nickname: self.host_nickname)
    user = User.where(id: self.user_id)
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i

    if self.status == 'pending' && host.length == 1
      profile = HostProfile.where(user_id: host[0].id)
      new_availability = (profile[0].availability + self.dates).sort
      profile.update(availability: new_availability)
      self.destroy
    elsif self.status == 'accepted' && self.dates[self.dates.length - 1] > now_epoch_javascript
      profile = HostProfile.where(user_id: host[0].id)
      new_forbidden_dates = (profile[0].forbidden_dates + self.dates).sort
      profile.update(forbidden_dates: new_forbidden_dates)
      BookingsMailer.notify_host_on_user_account_deletion(host[0], self, user[0]).deliver
      self.destroy
    else
      self.destroy
    end
  end

end
