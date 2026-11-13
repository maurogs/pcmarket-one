# Admin-managed content (categories, filters, collections) stores one value per
# locale in a jsonb column named "<attribute>_translations".
module Translatable
  extend ActiveSupport::Concern

  class_methods do
    # Methods live in an included module so models can override them and call super.
    def translates(*attributes)
      accessors = Module.new
      include accessors

      attributes.each do |attribute|
        column = "#{attribute}_translations"

        accessors.define_method(attribute) do |locale = I18n.locale|
          values = public_send(column) || {}
          values[locale.to_s].presence ||
            I18n.fallbacks[locale].lazy.map { |fallback| values[fallback.to_s].presence }.find(&:itself) ||
            values.values.find(&:present?)
        end

        I18n.available_locales.each do |locale|
          accessors.define_method("#{attribute}_#{locale}") { public_send(column)&.dig(locale.to_s) }
          accessors.define_method("#{attribute}_#{locale}=") do |value|
            public_send("#{column}=", (public_send(column) || {}).merge(locale.to_s => value.to_s.strip))
          end
        end
      end
    end
  end
end
