# Notice-and-action mechanism required by the EU Digital Services Act (art. 16).
class Report < ApplicationRecord
  REPORTABLE_TYPES = %w[Listing User Message Review].freeze

  enum :reason, { prohibited_item: 0, counterfeit: 1, scam: 2, misleading: 3, offensive: 4,
                  intellectual_property: 5, illegal_content: 6, spam: 7, other: 8 }, default: :other
  enum :status, { open: 0, reviewing: 1, resolved: 2, dismissed: 3 }, default: :open

  belongs_to :reporter, class_name: "User", optional: true
  belongs_to :reportable, polymorphic: true
  belongs_to :resolved_by, class_name: "User", optional: true

  validates :reportable_type, inclusion: { in: REPORTABLE_TYPES }
  validates :details, length: { maximum: 3_000 }
  validates :details, presence: true, if: -> { other? || illegal_content? || intellectual_property? }
  validates :reporter_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { reporter.nil? }

  scope :recent, -> { order(created_at: :desc) }

  def close!(moderator, status, note)
    update!(status: status, resolution_note: note, resolved_by: moderator, resolved_at: Time.current)
  end
end
