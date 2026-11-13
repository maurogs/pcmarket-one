class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :seller, class_name: "User", counter_cache: :followers_count
  validates :seller_id, uniqueness: { scope: :follower_id }
  validate { errors.add(:seller, :invalid) if follower_id == seller_id }
end
