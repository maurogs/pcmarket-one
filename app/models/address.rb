class Address < ApplicationRecord
  belongs_to :user

  validates :full_name, :line1, :city, :postal_code, :country_code, presence: true
  validates :full_name, :line1, :line2, :city, :region, :company, length: { maximum: 120 }
  validates :country_code, inclusion: { in: Country::SUPPORTED }
  validates :postal_code, format: { with: /\A[0-9A-Z \-]{3,10}\z/i }
  validates :phone, format: { with: /\A\+?[0-9 ()\-]{6,20}\z/ }, allow_blank: true
  validate :country_enabled

  after_save :unset_other_defaults, if: :default?

  def to_snapshot
    attributes.slice("full_name", "company", "line1", "line2", "city", "region", "postal_code", "country_code", "phone")
  end

  def one_line
    [line1, line2, "#{postal_code} #{city}", region, country_code].compact_blank.join(", ")
  end

  private

  def country_enabled
    errors.add(:country_code, :not_shipping_there) unless Country.enabled_codes.include?(country_code)
  end

  def unset_other_defaults
    user.addresses.where.not(id: id).update_all(default: false)
  end
end
