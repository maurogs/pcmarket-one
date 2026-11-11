class Offer < ApplicationRecord
  include Monetizable
  monetize :amount

  enum :status, { pending: 0, accepted: 1, declined: 2, withdrawn: 3, expired: 4, purchased: 5 }, default: :pending

  belongs_to :listing
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :conversation, optional: true
  has_many :messages, dependent: :nullify

  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validate :amount_is_reasonable, on: :create
  validate :listing_accepts_offers, on: :create
  validate :single_pending_offer, on: :create

  before_validation :assign_defaults, on: :create

  scope :open, -> { pending.where("expires_at > ?", Time.current) }
  scope :expirable, -> { pending.where(expires_at: ..Time.current) }

  def active? = pending? && expires_at.future?
  def usable? = accepted? && responded_at.present? && responded_at > 3.days.ago && listing.available?

  def accept!(actor)
    raise ArgumentError unless actor == seller && active?

    update!(status: :accepted, responded_at: Time.current)
    conversation&.post!(sender: seller, kind: :system, body: "offer_accepted", offer: self)
    Notification.deliver(buyer, :offer_accepted, path: AppRoutes.helpers.conversation_path(conversation), title: listing.title)
  end

  def decline!(actor)
    raise ArgumentError unless actor == seller && active?

    update!(status: :declined, responded_at: Time.current)
    conversation&.post!(sender: seller, kind: :system, body: "offer_declined", offer: self)
    Notification.deliver(buyer, :offer_declined, path: AppRoutes.helpers.conversation_path(conversation), title: listing.title)
  end

  def withdraw!(actor)
    raise ArgumentError unless actor == buyer && pending?

    update!(status: :withdrawn, responded_at: Time.current)
  end

  private

  def assign_defaults
    self.seller ||= listing&.user
    self.expires_at ||= Setting.get(:offer_expiry_hours).hours.from_now
  end

  def amount_is_reasonable
    return if listing.nil? || amount_cents.nil?

    minimum = (listing.price_cents * Setting.get(:min_offer_percent) / 100.0).ceil
    errors.add(:amount, :offer_too_low, minimum: minimum / 100.0) if amount_cents < minimum
    errors.add(:amount, :offer_too_high) if amount_cents >= listing.price_cents
  end

  def listing_accepts_offers
    return if listing.nil?

    errors.add(:base, :offers_not_allowed) unless Setting.enabled?(:offers_enabled) && listing.allow_offers? && listing.available?
    errors.add(:base, :cannot_offer_own_listing) if buyer_id == listing.user_id
  end

  def single_pending_offer
    return unless listing && buyer

    errors.add(:base, :offer_already_pending) if Offer.open.where(listing: listing, buyer: buyer).exists?
  end
end
