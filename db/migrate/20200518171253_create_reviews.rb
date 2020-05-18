class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.integer :score
      t.text :body
      t.text :host_reply
      t.string :host_nickname
      t.references :user, foreign_key: true
      t.references :host_profile, foreign_key: true
      t.references :booking, foreign_key: true

      t.timestamps
    end
  end
end
