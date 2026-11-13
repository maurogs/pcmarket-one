class Seller::DiscountCodesController < Seller::BaseController
  before_action { require_feature!(:discount_codes_enabled) }

  def index
    @discount_codes = current_user.discount_codes.order(created_at: :desc)
    @discount_code = current_user.discount_codes.new(percent_off: 10)
  end

  def create
    @discount_code = current_user.discount_codes.new(code_params)
    if @discount_code.save
      redirect_to seller_discount_codes_path, notice: t(".success")
    else
      @discount_codes = current_user.discount_codes.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    current_user.discount_codes.find(params[:id]).update(active: params[:active] == "1")
    redirect_to seller_discount_codes_path, notice: t(".success")
  end

  def destroy
    current_user.discount_codes.find(params[:id]).destroy
    redirect_to seller_discount_codes_path, notice: t(".success"), status: :see_other
  end

  private

  def code_params
    params.require(:discount_code).permit(:code, :percent_off, :max_uses, :expires_at)
  end
end
