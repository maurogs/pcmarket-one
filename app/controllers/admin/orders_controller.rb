class Admin::OrdersController < Admin::BaseController
  before_action :set_order, except: :index

  def index
    scope = Order.includes(:buyer, :seller)
    scope = scope.where(status: params[:status]) if Order.statuses.key?(params[:status])
    if params[:q].present?
      term = "%#{Order.sanitize_sql_like(params[:q])}%"
      scope = scope.joins(:buyer).where("orders.number ILIKE :t OR orders.email ILIKE :t OR users.username ILIKE :t", t: term)
    end
    scope = scope.where(created_at: Date.parse(params[:from])..) if params[:from].present?
    scope = scope.where(created_at: ..Date.parse(params[:to]).end_of_day) if params[:to].present?
    @status_counts = Order.group(:status).count
    @totals = scope.unscope(:includes).pick(Arel.sql("COALESCE(SUM(total_cents),0), COALESCE(SUM(platform_fee_cents),0)"))
    respond_to do |format|
      format.html { @pagy, @orders = paginate(sorted(scope, %w[created_at total_cents paid_at], "created_at")) }
      format.csv { send_data AdminCsv.orders(scope), filename: "orders-#{Date.current}.csv" }
    end
  rescue Date::Error
    redirect_to admin_orders_path, alert: t("admin.flash.invalid_date")
  end

  def show
    @events = @order.events.includes(:actor)
  end

  def update
    if params[:status].present?
      @order.transition!(params[:status], actor: current_user, note: params[:note].presence || "admin")
      audit!("order.#{params[:status]}", @order, note: params[:note])
    else
      @order.update!(params.require(:order).permit(:carrier, :tracking_number))
      audit!("order.updated", @order)
    end
    redirect_to admin_order_path(@order), notice: t("admin.flash.updated")
  rescue Order::InvalidTransition
    redirect_to admin_order_path(@order), alert: t("orders.errors.invalid_transition")
  end

  private

  def set_order
    @order = Order.includes(:buyer, :seller, items: :listing).find_by!(number: params[:id])
  end
end
