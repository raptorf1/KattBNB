class AddHiidenToConversations < ActiveRecord::Migration[5.2]
  def change
    add_column :conversations, :hidden, :integer
  end
end
