class Admin::CountriesController < Admin::BaseController
  before_action :require_admin!
  before_action :set_country, only: %i[edit update]

  def index
    @countries = Country.ordered
    @listing_counts = Listing.visible.group(:country_id).count
    @user_counts = User.group(:country_id).count
  end

  def edit; end

  def update
    legal = params.fetch(:legal, {}).permit(*LegalFacts.for(@country.code).keys).to_h.compact_blank
    if @country.update(params.require(:country).permit(:enabled, :default_locale, :currency, :vat_rate, :position).merge(legal: legal))
      audit!("country.updated", @country, @country.saved_changes.except("updated_at"))
      redirect_to admin_countries_path, notice: t("admin.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_country
    @country = Country.find_by!(code: params[:id].to_s.upcase)
  end
end
