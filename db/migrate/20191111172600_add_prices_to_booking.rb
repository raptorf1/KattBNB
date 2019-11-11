class AddPricesToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :price_per_day, :float
    add_column :bookings, :price_total, :float
  end
end
