class AddMessageNotificationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :message_notification, :boolean, default: true
  end
end
