class LegalPagesController < ApplicationController
  def show
    @slug = params[:id].to_s.tr("-", "_")
    raise ActiveRecord::RecordNotFound unless LegalPage::SLUGS.include?(@slug)

    @country = params[:country].present? ? Country.enabled.find_by!(code: params[:country].to_s.upcase) : current_country
    @override = LegalPage.published.find_by(slug: @slug, country_code: @country.code, locale: I18n.locale.to_s)
    @document = LegalDocument.new(@slug, @country)
    fresh_when etag: [ @slug, @country, @override, I18n.locale ], public: true unless user_signed_in?
  end
end
