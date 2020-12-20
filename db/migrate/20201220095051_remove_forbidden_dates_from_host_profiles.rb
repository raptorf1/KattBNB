class RemoveForbiddenDatesFromHostProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :host_profiles, :forbidden_dates
  end
end
