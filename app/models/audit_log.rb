class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  scope :recent, -> { order(created_at: :desc) }

  def self.record(actor, action, auditable = nil, details = {}, ip: nil)
    create!(actor: actor, action: action, auditable: auditable, details: details, ip_address: ip)
  end
end
