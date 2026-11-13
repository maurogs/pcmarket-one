class Account::ProfilesController < Account::BaseController
  def edit; end

  def update
    if current_user.update(params.require(:user).permit(:first_name, :last_name, :username, :phone, :bio, :locale, :region_id, :city, :avatar))
      redirect_to edit_account_profile_path(locale: current_user.locale == I18n.default_locale.to_s ? nil : current_user.locale), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
