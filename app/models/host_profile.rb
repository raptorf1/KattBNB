class HostProfile < ApplicationRecord
  before_create :assign_stripe_state
  after_commit :expire_all_cache

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

  def self.location_cached(location)
    if Rails.cache.fetch("host_profiles_#{location}").nil?
      response = HostProfile.joins(:user).where(users: { location: location })
      Rails.cache.fetch("host_profiles_#{location}") { response }
      response
    else
      Rails.cache.fetch("host_profiles_#{location}")
    end
  end

  def self.all_cached
    if Rails.cache.fetch("host_profiles_all").nil?
      response = HostProfile.all
      Rails.cache.fetch("host_profiles_all") { response }
      response
    else
      Rails.cache.fetch("host_profiles_all")
    end
  end

  def expire_all_cache
    Rails.cache.clear
  end
end
