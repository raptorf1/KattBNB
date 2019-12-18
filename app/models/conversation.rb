class Conversation < ApplicationRecord
  belongs_to :user1, :class_name => 'User'
  belongs_to :user2, :class_name => 'User'
  #validates_presence_of :number_of_cats, :message, :dates, :host_nickname, :status, :price_per_day, :price_total, :user_id

end