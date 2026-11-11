class Account::StoresController < Account::BaseController
  def edit; end

  def update
    attributes = params.require(:user).permit(:store_name, :store_tagline, :bio, :seller_type, :legal_name, :tax_id,
                                              :business_address, :trade_register_number, :store_logo, :store_banner,
                                              :allow_offers_default, :return_window_days, :store_policies)
    current_user.assign_attributes(attributes)
    current_user.trader_certified_at = Time.current if params[:trader_certification] == "1" && current_user.business?
    if current_user.save
      redirect_to edit_account_store_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
