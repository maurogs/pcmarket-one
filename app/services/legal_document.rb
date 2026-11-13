# Renders a legal page from the locale templates (config/locales/*/legal.*.yml),
# interpolating the country-specific facts (statutes, regulators, company data).
class LegalDocument
  attr_reader :slug, :country

  def initialize(slug, country)
    @slug = slug
    @country = country
  end

  def title = I18n.t("legal.#{slug}.title")
  def updated_on = I18n.t("legal.updated_on")

  def sections
    sections = I18n.t("legal.#{slug}.sections", default: {}).to_a
    extra = I18n.t("legal.#{slug}.country_sections.#{country.code.downcase}", default: nil)
    sections += extra.to_a if extra.is_a?(Hash)
    sections.map do |key, section|
      { key: key, heading: interpolate(section[:heading]), paragraphs: Array(section[:body]).map { |p| interpolate(p) } }
    end
  end

  private

  def facts
    @facts ||= LegalFacts.for(country.code).merge(country.legal.to_h).merge(
      "site_name" => Setting.get(:site_name), "country_name" => country.name,
      "support_email" => Setting.get(:support_email), "protection_days" => Setting.get(:buyer_protection_days).to_s,
      "ship_days" => Setting.get(:seller_ship_days).to_s, "vat_rate" => country.vat_rate.to_s
    ).symbolize_keys
  end

  def interpolate(text)
    text.to_s.gsub(/%\{(\w+)\}/) { facts.fetch(Regexp.last_match(1).to_sym, "") }
  end
end
