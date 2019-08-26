class RemoveAvailabilityFromHostProfile < ActiveRecord::Migration[5.2]
  def change
    remove_column :host_profiles, :availability, :text
  end
end
