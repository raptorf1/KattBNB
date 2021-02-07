class HostProfile < ApplicationRecord
  before_create :assign_stripe_state

  belongs_to :user

  has_many :review, dependent: :nullify

  validates_presence_of :description,
                        :full_address,
                        :price_per_day_1_cat,
                        :supplement_price_per_cat_per_day,
                        :max_cats_accepted

  def assign_stripe_state
    self.stripe_state = SecureRandom.hex + self.user.nickname
  end
end
