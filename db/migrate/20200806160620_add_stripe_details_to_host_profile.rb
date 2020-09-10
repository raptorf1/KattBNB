class AddStripeDetailsToHostProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :host_profiles, :stripe_state, :string
    add_column :host_profiles, :stripe_account_id, :string
  end
end
