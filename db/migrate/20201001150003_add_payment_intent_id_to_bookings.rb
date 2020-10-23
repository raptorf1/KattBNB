class AddPaymentIntentIdToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :payment_intent_id, :string
  end
end
