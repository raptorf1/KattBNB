class CreateHostProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :host_profiles do |t|
      t.references :user, foreign_key: true
      t.text :description
      t.string :full_address
      t.decimal :price_per_day_1_cat
      t.decimal :supplement_price_per_cat_per_day
      t.integer :max_cats_accepted
      t.text :availability, array: true, default: []
      t.decimal :lat
      t.decimal :long

      t.timestamps
    end
  end
end
