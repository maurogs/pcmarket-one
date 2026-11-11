class NewsletterSubscription < ApplicationRecord
  has_secure_token :token

  normalizes :email, with: ->(email) { email.strip.downcase }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true

  scope :active, -> { where.not(confirmed_at: nil).where(unsubscribed_at: nil) }

  def confirm! = update!(confirmed_at: Time.current, unsubscribed_at: nil)
  def unsubscribe! = update!(unsubscribed_at: Time.current)
end
