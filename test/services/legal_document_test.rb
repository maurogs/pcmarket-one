require "test_helper"

class LegalDocumentTest < ActiveSupport::TestCase
  test "renders every legal page in every locale with country facts" do
    %w[ES FR GB DE IT PT].each do |code|
      country = Country.find_or_create_by!(code: code)
      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          LegalPage::SLUGS.each do |slug|
            document = LegalDocument.new(slug, country)
            assert document.sections.any?, "#{slug} #{locale} has no sections"
            text = document.sections.flat_map { |s| s[:paragraphs] }.join
            assert_no_match(/%\{/, text, "#{slug} #{locale} #{code} has uninterpolated placeholders")
          end
        end
      end
    end
  end

  test "German legal notice includes the Impressum" do
    document = LegalDocument.new("legal_notice", Country.find_or_create_by!(code: "DE"))
    assert document.sections.any? { |s| s[:key] == :impressum }
  end
end
