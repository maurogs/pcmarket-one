class SupportTicket < ApplicationRecord
  enum :topic, { general: 0, order_issue: 1, payment: 2, account: 3, selling: 4, legal: 5, privacy_request: 6 }, default: :general
  enum :status, { open: 0, pending: 1, closed: 2 }, default: :open

  belongs_to :user, optional: true

  validates :name, :email, :subject, :body, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, length: { maximum: 150 }
  validates :body, length: { maximum: 5_000 }

  scope :recent, -> { order(created_at: :desc) }
end
