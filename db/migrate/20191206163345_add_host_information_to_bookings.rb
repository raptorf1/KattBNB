class AddHostInformationToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :host_description, :text
    add_column :bookings, :host_full_address, :string
    add_column :bookings, :host_avatar, :text
    add_column :bookings, :host_real_lat, :decimal
    add_column :bookings, :host_real_long, :decimal
  end
end
