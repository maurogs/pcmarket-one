class Admin::LegalPagesController < Admin::BaseController
  before_action :require_admin!
  before_action :set_page, only: %i[edit update destroy]

  def index
    @pages = LegalPage.order(:country_code, :slug, :locale)
  end

  def new
    @page = LegalPage.new(slug: params[:slug], country_code: params[:country_code] || "ES", locale: I18n.locale)
    prefill(@page)
  end

  def create
    @page = LegalPage.new(page_params)
    @page.save ? redirect_to(admin_legal_pages_path, notice: t("admin.flash.created")) : render(:new, status: :unprocessable_entity)
  end

  def edit; end

  def update
    @page.update(page_params) ? redirect_to(admin_legal_pages_path, notice: t("admin.flash.updated")) : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @page.destroy
    redirect_to admin_legal_pages_path, notice: t("admin.flash.destroyed"), status: :see_other
  end

  private

  def set_page = @page = LegalPage.find(params[:id])
  def page_params = params.require(:legal_page).permit(:slug, :country_code, :locale, :title, :body, :published)

  # Starts the override from the default template so admins only edit what differs.
  def prefill(page)
    country = Country.find_by(code: page.country_code)
    return unless country && LegalPage::SLUGS.include?(page.slug)

    I18n.with_locale(page.locale) do
      document = LegalDocument.new(page.slug, country)
      page.title = document.title
      page.body = document.sections.map { |s| (["## #{s[:heading]}"] + s[:paragraphs]).join("\n\n") }.join("\n\n")
    end
  end
end
