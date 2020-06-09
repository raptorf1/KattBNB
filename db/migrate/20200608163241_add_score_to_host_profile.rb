class AddScoreToHostProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :host_profiles, :score, :float
  end
end
