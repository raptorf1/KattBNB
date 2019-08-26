class AddAvailabilityToHostProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :host_profiles, :availability, :bigint, array: true, default: []
  end
end
