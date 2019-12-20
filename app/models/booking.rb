class Booking < ApplicationRecord

  #before_destroy :test
  
  belongs_to :user

  enum status: [:accepted, :pending, :declined, :canceled]

  validates_presence_of :number_of_cats, :message, :dates, :host_nickname, :status, :price_per_day, :price_total, :user_id
  validates :message, length: { maximum: 400 }
  validates :host_message, length: { maximum: 200 }

  #def test
  #  binding.pry
  #   booking = Booking.find(params[:id])
  #   host = User.where(nickname: booking.host_nickname)
  #   user = User.where(id: booking.user_id)
  #   now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
  #   now_epoch_javascript = (now.to_f * 1000).to_i

  #   if current_api_v1_user.id == booking.user_id && booking.present? == true && booking.destroyed? == false
  #     if booking.status == 'declined' || booking.status == 'canceled'
  #       booking.destroy
  #       render json: { message: 'You have successfully deleted this declined or canceled booking' }, status: 200
  #     elsif booking.status == 'pending'
  #       profile = HostProfile.where(user_id: host[0].id)
  #       new_availability = (profile[0].availability + booking.dates).sort
  #       profile.update(availability: new_availability)
  #       booking.destroy
  #       render json: { message: 'You have successfully deleted this pending booking' }, status: 200
  #     elsif booking.status == 'accepted' && booking.dates[booking.dates.length - 1] > now_epoch_javascript
  #       BookingsMailer.notify_host_on_user_account_deletion(host[0], booking, user[0]).deliver
  #       booking.destroy
  #     else
  #       render json: { message: 'You have successfully deleted an accepted booking of the past' }, status: 200
  #       booking.destroy
  #     end
  #   else
  #     render json: { error: 'You cannot perform this action' }, status: 422
  #   end  
  #end

end
