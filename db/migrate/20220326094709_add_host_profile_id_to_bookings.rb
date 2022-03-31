class AddHostProfileIdToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :host_profile_id, :integer
  end
end
