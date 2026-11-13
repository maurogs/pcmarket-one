class Account::DeletionsController < Account::BaseController
  def new; end

  def create
    unless current_user.provider.present? || current_user.valid_password?(params[:password].to_s)
      return redirect_to(new_account_deletion_path, alert: t(".wrong_password"))
    end
    if current_user.sales.open.exists? || current_user.purchases.open.exists?
      return redirect_to(new_account_deletion_path, alert: t(".open_orders"))
    end

    user = current_user
    sign_out(user)
    user.anonymize!
    redirect_to root_path, notice: t(".success")
  end
end
