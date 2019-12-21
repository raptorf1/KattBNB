class AddForbiddenDatesToHostProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :host_profiles, :forbidden_dates, :bigint, array: true, default: []
  end
end
