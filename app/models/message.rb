class Message < ApplicationRecord
  MAX_LENGTH = 2_000
  # Basic anti-fraud: warn when users try to move the payment off-platform.
  OFF_PLATFORM_PATTERN = /\b(bizum|paypal\s*(friends|amigos)|western\s*union|transferencia|whats\s*app|telegram|iban)\b/i

  enum :kind, { text: 0, offer: 1, system: 2 }, default: :text

  belongs_to :conversation, touch: true
  belongs_to :sender, class_name: "User"
  belongs_to :offer, optional: true

  validates :body, presence: true, length: { maximum: MAX_LENGTH }, if: :text?

  normalizes :body, with: ->(body) { body.to_s.strip }

  after_create_commit :broadcast_and_notify

  def off_platform_warning?
    text? && body.to_s.match?(OFF_PLATFORM_PATTERN)
  end

  private

  def broadcast_and_notify
    broadcast_append_to conversation, target: "messages", partial: "messages/message", locals: { message: self, viewer: nil }
    recipient = conversation.other_participant(sender)
    return if text? && conversation.messages.where(sender: sender).where("created_at > ?", 10.minutes.ago).where.not(id: id).exists?

    MessageNotificationJob.perform_later(id, recipient.id)
  end
end
