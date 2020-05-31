class RemoveHostAvatarFromBookings < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings, :host_avatar
  end
end
