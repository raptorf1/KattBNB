class Review < ApplicationRecord
  after_create_commit :update_host_score

  belongs_to :user
  belongs_to :host_profile
  belongs_to :booking

  validates_presence_of :score, :body, :host_nickname
  validates :score, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
  validates :body, :host_reply, length: { maximum: 1000 }

  def update_host_score
    profile = HostProfile.find(self.host_profile_id)
    average_score = profile.review.sum(&:score) / profile.review.count.to_f
    profile.update_column(:score, average_score)
  end

  def self.get_high_score_reviews
    reviews = Review.where(score: 5)
    high_score_reviews = reviews.reject { |review| review.host_profile_id == nil }
    high_score_reviews.uniq(&:host_profile_id)
  end
end
