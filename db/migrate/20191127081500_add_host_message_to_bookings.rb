class AddHostMessageToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :host_message, :text
  end
end
