class Admin::PromotionsController < Admin::BaseController
  def index
    @pagy, @promotions = paginate(Promotion.includes(:listing, :user).order(created_at: :desc))
  end

  def update
    promotion = Promotion.find(params[:id])
    case params[:status]
    when "active" then promotion.activate!
    when "cancelled"
      promotion.update!(status: :cancelled)
      promotion.listing.update_columns(promoted_until: nil)
    end
    audit!("promotion.#{params[:status]}", promotion)
    redirect_to admin_promotions_path, notice: t("admin.flash.updated")
  end
end
