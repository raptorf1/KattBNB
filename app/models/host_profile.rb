class HostProfile < ApplicationRecord
  belongs_to :user

  has_many :review

  validates_presence_of :description, :full_address, :price_per_day_1_cat, :supplement_price_per_cat_per_day, :max_cats_accepted
end
