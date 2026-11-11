class Order < ApplicationRecord
  include Monetizable
  monetize :subtotal, :shipping, :discount, :platform_fee, :total

  enum :status, { pending_payment: 0, paid: 1, shipped: 2, delivered: 3, completed: 4,
                  cancelled: 5, refunded: 6, disputed: 7 }, default: :pending_payment
  enum :delivery_method, { shipping: 0, pickup: 1 }, default: :shipping, prefix: :delivery

  TRANSITIONS = {
    "pending_payment" => %w[paid cancelled],
    "paid" => %w[shipped delivered cancelled disputed],
    "shipped" => %w[delivered disputed],
    "delivered" => %w[completed disputed],
    "disputed" => %w[completed refunded],
    "completed" => %w[refunded],
    "cancelled" => [],
    "refunded" => []
  }.freeze
  OPEN_STATUSES = %w[pending_payment paid shipped delivered disputed].freeze

  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :discount_code, optional: true
  has_many :items, class_name: "OrderItem", dependent: :destroy
  has_many :events, -> { order(:created_at) }, class_name: "OrderEvent", dependent: :delete_all
  has_one :review, dependent: :destroy

  validates :number, presence: true, uniqueness: true
  validates :email, presence: true
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :tracking_number, length: { maximum: 60 }
  validates :shipping_address, presence: true, if: :delivery_shipping?

  before_validation :assign_number, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :open, -> { where(status: OPEN_STATUSES) }
  scope :for_participant, ->(user) { where(buyer_id: user.id).or(where(seller_id: user.id)) }

  def to_param = number

  def can_transition_to?(target) = TRANSITIONS.fetch(status, []).include?(target.to_s)

  def transition!(target, actor: nil, note: nil, **attributes)
    target = target.to_s
    raise InvalidTransition, "#{status} -> #{target}" unless can_transition_to?(target)

    transaction do
      lock!
      previous = status
      assign_attributes(attributes.merge(status: target))
      self["#{target}_at"] = Time.current if has_attribute?("#{target}_at")
      self.protection_ends_at = Time.current + Setting.get(:buyer_protection_days).days if target == "delivered"
      save!
      events.create!(actor: actor, from_status: previous, to_status: target, note: note)
      release_stock! if %w[cancelled refunded].include?(target) && previous != "completed"
      seller.increment!(:sales_count) if target == "completed"
    end
    OrderNotifier.new(self).status_changed
    self
  end

  def mark_paid!(reference:, provider:)
    transition!(:paid, note: provider, payment_reference: reference, payment_provider: provider)
  end

  def ship!(actor, carrier:, tracking_number:)
    raise NotAllowed unless actor == seller

    transition!(:shipped, actor: actor, carrier: carrier, tracking_number: tracking_number)
  end

  def confirm_delivery!(actor)
    raise NotAllowed unless [buyer, seller].include?(actor) || actor&.staff?

    transition!(:delivered, actor: actor)
  end

  def accept!(actor)
    raise NotAllowed unless actor == buyer || actor&.staff?

    transition!(:completed, actor: actor)
  end

  def cancel!(actor, reason)
    allowed = actor&.staff? || (actor == buyer && (pending_payment? || ship_deadline_passed?)) || (actor == seller && paid?)
    raise NotAllowed unless allowed

    transition!(:cancelled, actor: actor, note: reason, cancel_reason: reason)
  end

  def dispute!(actor, reason)
    raise NotAllowed unless actor == buyer && within_protection_window?

    transition!(:disputed, actor: actor, note: reason, dispute_reason: reason)
  end

  def ship_deadline
    paid_at && paid_at + Setting.get(:seller_ship_days).days
  end

  def ship_deadline_passed?
    paid? && ship_deadline&.past?
  end

  def within_protection_window?
    paid? || shipped? || (delivered? && protection_ends_at&.future?)
  end

  def reviewable_by?(user)
    Setting.enabled?(:reviews_enabled) && completed? && user == buyer && (review.nil? || review.new_record?)
  end

  def participant?(user) = user && [buyer_id, seller_id].include?(user.id)

  def title
    items.first&.title.to_s + (items.size > 1 ? " +#{items.size - 1}" : "")
  end

  class InvalidTransition < StandardError; end
  class NotAllowed < StandardError; end

  private

  def assign_number
    self.number ||= loop do
      candidate = "PCM-#{Time.current.strftime('%y%m')}-#{SecureRandom.alphanumeric(6).upcase}"
      break candidate unless Order.exists?(number: candidate)
    end
  end

  def release_stock!
    items.includes(:listing).each do |item|
      item.listing.lock!
      item.listing.release_stock!(item.quantity)
    end
  end
end
