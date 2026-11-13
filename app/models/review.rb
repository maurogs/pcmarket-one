class Review < ApplicationRecord
  enum :status, { visible: 0, hidden: 1 }, default: :visible

  belongs_to :order
  belongs_to :reviewer, class_name: "User"
  belongs_to :seller, class_name: "User"

  validates :rating, inclusion: { in: 1..5 }
  validates :body, length: { maximum: 2_000 }
  validates :seller_reply, length: { maximum: 1_000 }
  validates :order_id, uniqueness: true
  validate :order_is_reviewable, on: :create

  before_validation(on: :create) { self.seller ||= order&.seller }
  after_commit -> { seller.refresh_reputation! }

  scope :recent, -> { order(created_at: :desc) }

  private

  def order_is_reviewable
    errors.add(:base, :not_reviewable) unless order&.reviewable_by?(reviewer)
  end
end
