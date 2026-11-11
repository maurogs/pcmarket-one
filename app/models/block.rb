class Block < ApplicationRecord
  belongs_to :blocker, class_name: "User"
  belongs_to :blocked, class_name: "User"
  validates :blocked_id, uniqueness: { scope: :blocker_id }
  validate { errors.add(:blocked, :invalid) if blocker_id == blocked_id }

  def self.between?(a, b)
    return false if a.nil? || b.nil?

    where(blocker: a, blocked: b).or(where(blocker: b, blocked: a)).exists?
  end
end
