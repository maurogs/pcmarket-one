class Admin::UsersController < Admin::BaseController
  before_action :set_user, except: :index

  def index
    scope = User.includes(:country, avatar_attachment: :blob)
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.where(status: params[:status]) if User.statuses.key?(params[:status])
    scope = scope.where(role: params[:role]) if User.roles.key?(params[:role])
    scope = scope.where(seller_type: params[:seller_type]) if User.seller_types.key?(params[:seller_type])
    scope = scope.where.not(verified_at: nil) if params[:verified] == "1"
    scope = scope.where(confirmed_at: nil) if params[:unconfirmed] == "1"
    scope = scope.where(deleted_at: nil) unless params[:deleted] == "1"
    @pagy, @users = paginate(sorted(scope, %w[created_at last_sign_in_at listings_count sales_count rating_avg], "created_at"))
  end

  def show
    @listings = @user.listings.order(created_at: :desc).limit(10)
    @sales = @user.sales.recent.limit(10)
    @purchases = @user.purchases.recent.limit(10)
    @reports = Report.where(reportable: @user).or(Report.where(reportable_type: "Listing", reportable_id: @user.listings.select(:id))).recent.limit(10)
    @audit = AuditLog.where(auditable: @user).recent.limit(20)
  end

  def edit; end

  def update
    attributes = params.require(:user).permit(:username, :email, :first_name, :last_name, :phone, :status, :suspension_reason,
                                              :store_name, :seller_type, :vacation_mode, :locale)
    role = params.dig(:user, :role)
    attributes[:role] = role if current_user.admin? && @user != current_user && User.roles.key?(role)
    @user.skip_reconfirmation! if attributes.key?(:email)
    @user.assign_attributes(attributes)
    @user.verified_at = params.dig(:user, :verified) == "1" ? (@user.verified_at || Time.current) : nil if params.dig(:user, :verified)
    @user.confirmed_at ||= Time.current if params.dig(:user, :confirm) == "1"
    if @user.save
      @user.refresh_listings_count!
      audit!("user.updated", @user, @user.saved_changes.except("updated_at", "encrypted_password"))
      redirect_to admin_user_path(@user), notice: t("admin.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by!("lower(username) = ?", params[:id].to_s.downcase)
    authorize!(current_user.admin? || !@user.staff? || @user == current_user) unless action_name == "show"
  end
end
