class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :listing, counter_cache: true
  validates :listing_id, uniqueness: { scope: :user_id }
end
