class BuybackRequest < ApplicationRecord
  enum :condition, { working: 0, minor_issues: 1 }, default: :working
  enum :status, { submitted: 0, accepted: 1, label_sent: 2, received: 3, paid: 4, rejected: 5, cancelled: 6 }, default: :submitted

  belongs_to :user
  belongs_to :filter_option

  validates :quoted_cents, numericality: { greater_than: 0 }
  validates :paypal_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation(on: :create) do
    base = filter_option&.buyback_cents.to_i
    self.quoted_cents = minor_issues? ? (base * 0.6).round : base
  end
end
