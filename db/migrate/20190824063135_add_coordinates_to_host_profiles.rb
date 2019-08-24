class AddCoordinatesToHostProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :host_profiles, :latitude, :decimal
    add_column :host_profiles, :longitude, :decimal
  end
end
