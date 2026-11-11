module Monetizable
  extend ActiveSupport::Concern

  class_methods do
    # Exposes "<name>" as a decimal amount backed by an integer "<name>_cents" column.
    def monetize(*attributes)
      attributes.each do |attribute|
        define_method(attribute) do
          cents = public_send("#{attribute}_cents")
          cents && (cents / 100.0)
        end

        define_method("#{attribute}=") do |value|
          normalized = value.to_s.tr(",", ".").gsub(/[^\d.]/, "")
          public_send("#{attribute}_cents=", normalized.present? ? (BigDecimal(normalized) * 100).round : nil)
        end
      end
    end
  end
end
