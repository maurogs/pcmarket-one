class Notification < ApplicationRecord
  KINDS = %w[listing_approved listing_rejected new_message new_offer offer_accepted offer_declined
             order_placed order_paid order_shipped order_delivered order_completed order_cancelled
             order_disputed new_review saved_search_match new_follower followed_seller_listing].freeze

  belongs_to :user

  validates :kind, inclusion: { in: KINDS }

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit -> {
    broadcast_replace_to [ user, :notifications ], target: "notification_badge",
      partial: "notifications/badge", locals: { count: user.unread_notifications_count }
  }

  def self.deliver(user, kind, path: nil, **params)
    return if user.nil? || user.deleted?

    create!(user: user, kind: kind.to_s, params: params, path: path)
  end

  def message
    I18n.t("notifications.kinds.#{kind}", **params.symbolize_keys)
  end

  def read? = read_at.present?
end
