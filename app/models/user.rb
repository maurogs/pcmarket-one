class User < ApplicationRecord
  include ImageValidation

  USERNAME_FORMAT = /\A[a-zA-Z0-9_\-.]{3,30}\z/

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :confirmable, :lockable, :trackable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  enum :role, { member: 0, moderator: 1, admin: 2 }, default: :member
  enum :status, { active: 0, suspended: 1, banned: 2 }, default: :active
  enum :seller_type, { individual: 0, business: 1 }, default: :individual

  belongs_to :country, optional: true
  belongs_to :region, optional: true

  has_one_attached :avatar
  has_one_attached :store_logo
  has_one_attached :store_banner

  has_many :listings, dependent: :destroy
  has_many :published_listings, -> { visible }, class_name: "Listing"
  has_many :favorites, dependent: :delete_all
  has_many :favorite_listings, through: :favorites, source: :listing
  has_many :saved_searches, dependent: :delete_all
  has_many :notifications, dependent: :delete_all
  has_many :addresses, -> { order(default: :desc, created_at: :desc) }, dependent: :delete_all
  has_many :api_tokens, dependent: :delete_all
  has_many :discount_codes, foreign_key: :seller_id, dependent: :delete_all
  has_many :active_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :delete_all
  has_many :followed_sellers, through: :active_follows, source: :seller
  has_many :passive_follows, class_name: "Follow", foreign_key: :seller_id, dependent: :delete_all
  has_many :followers, through: :passive_follows, source: :follower
  has_many :blocks_made, class_name: "Block", foreign_key: :blocker_id, dependent: :delete_all
  has_many :blocked_users, through: :blocks_made, source: :blocked
  has_many :purchases, class_name: "Order", foreign_key: :buyer_id, dependent: :restrict_with_error
  has_many :sales, class_name: "Order", foreign_key: :seller_id, dependent: :restrict_with_error
  has_many :reviews_received, -> { visible }, class_name: "Review", foreign_key: :seller_id
  has_many :buyer_conversations, class_name: "Conversation", foreign_key: :buyer_id, dependent: :destroy
  has_many :seller_conversations, class_name: "Conversation", foreign_key: :seller_id, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :buyback_requests, dependent: :destroy
  has_many :offers_made, class_name: "Offer", foreign_key: :buyer_id, dependent: :destroy
  has_many :offers_received, class_name: "Offer", foreign_key: :seller_id, dependent: :destroy
  has_many :reviews_written, class_name: "Review", foreign_key: :reviewer_id, dependent: :destroy
  has_many :all_reviews_received, class_name: "Review", foreign_key: :seller_id, dependent: :destroy
  has_many :reports_made, class_name: "Report", foreign_key: :reporter_id, dependent: :nullify
  has_many :support_tickets, dependent: :nullify
  has_many :promotions, dependent: :destroy
  has_many :listing_events, foreign_key: :actor_id, dependent: :nullify
  has_many :order_events, foreign_key: :actor_id, dependent: :nullify
  has_many :audit_logs, foreign_key: :actor_id, dependent: :nullify

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :username, with: ->(name) { name.strip }

  validates :username, presence: true, format: { with: USERNAME_FORMAT },
                       uniqueness: { case_sensitive: false }
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }
  validates :store_name, length: { maximum: 60 }
  validates :store_tagline, length: { maximum: 140 }
  validates :bio, length: { maximum: 1_000 }
  validates :legal_name, :tax_id, :business_address, presence: true, if: -> { business? && trader_certified_at.present? }
  validates :return_window_days, inclusion: { in: [0, 14, 30, 60] }
  validates_images :avatar, :store_logo, :store_banner

  before_validation :assign_username, on: :create
  before_validation :assign_country, on: :create

  scope :sellers, -> { where("listings_count > 0") }
  scope :staff, -> { where(role: %i[moderator admin]) }
  scope :search, ->(term) {
    pattern = "%#{sanitize_sql_like(term.to_s.strip)}%"
    where("email ILIKE :p OR username ILIKE :p OR store_name ILIKE :p OR first_name ILIKE :p OR last_name ILIKE :p", p: pattern)
  }

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid) || find_by(email: auth.info.email.to_s.downcase)
    return user.tap { |u| u.update(provider: auth.provider, uid: auth.uid) unless u.provider } if user

    create(
      provider: auth.provider, uid: auth.uid, email: auth.info.email,
      password: Devise.friendly_token[0, 32], first_name: auth.info.first_name,
      last_name: auth.info.last_name, confirmed_at: Time.current, terms_accepted_at: Time.current
    )
  end

  def display_name
    store_name.presence || username
  end

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence || username
  end

  def staff? = moderator? || admin?
  def verified? = verified_at.present?
  def deleted? = deleted_at.present?

  def active_for_authentication?
    super && !banned? && !deleted?
  end

  def inactive_message
    banned? ? :banned : super
  end

  def can_sell?
    active? && confirmed?
  end

  def favorited?(listing)
    favorite_ids.include?(listing.id)
  end

  def favorite_ids
    @favorite_ids ||= favorites.pluck(:listing_id).to_set
  end

  def following?(seller)
    active_follows.exists?(seller_id: seller.id)
  end

  def blocked?(other)
    Block.between?(self, other)
  end

  def unread_messages_count
    Conversation.where(buyer_id: id).sum(:buyer_unread_count) +
      Conversation.where(seller_id: id).sum(:seller_unread_count)
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def notify_by_email?(kind)
    notification_preferences.fetch(kind.to_s, true) != false
  end

  def refresh_reputation!
    stats = Review.visible.where(seller_id: id).pick(Arel.sql("COUNT(*), COALESCE(AVG(rating), 0)"))
    update_columns(reviews_count: stats[0], rating_avg: stats[1].to_d.round(2))
  end

  def refresh_listings_count!
    update_column(:listings_count, listings.visible.count)
  end

  # GDPR right to erasure: anonymise personal data but keep orders for accounting duties.
  def anonymize!
    transaction do
      listings.where.not(status: :sold).find_each(&:archive!)
      update_columns(
        email: "deleted-#{id}@deleted.invalid", username: "deleted-#{id}", first_name: nil, last_name: nil,
        phone: nil, bio: nil, store_name: nil, store_tagline: nil, provider: nil, uid: nil,
        city: nil, deleted_at: Time.current, encrypted_password: ""
      )
      [avatar, store_logo, store_banner].each(&:purge_later)
      api_tokens.delete_all
    end
  end

  def to_param
    username
  end

  private

  def assign_username
    return if username.present?

    base = email.to_s.split("@").first.to_s.gsub(/[^a-zA-Z0-9_]/, "").first(20).presence || "user"
    candidate = base
    candidate = "#{base}#{SecureRandom.random_number(10_000)}" while candidate.length < 3 || User.where("lower(username) = ?", candidate.downcase).exists?
    self.username = candidate
  end

  def assign_country
    self.country ||= Country.default
  end
end
