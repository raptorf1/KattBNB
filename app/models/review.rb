class Review < ApplicationRecord
  belongs_to :user
  belongs_to :hostProfile
  belongs_to :booking
end
