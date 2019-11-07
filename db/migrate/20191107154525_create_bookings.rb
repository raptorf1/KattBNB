class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.integer :number_of_cats
      t.text :message
      t.bigint :dates, array: true
      t.integer :status, default: 1
      t.string :host_nickname
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
