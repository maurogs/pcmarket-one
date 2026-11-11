class AdminStats
  PERIODS = { "7d" => 7, "30d" => 30, "90d" => 90 }.freeze

  attr_reader :period

  def initialize(period: nil)
    @period = PERIODS.key?(period) ? period : "30d"
  end

  def since = PERIODS[period].days.ago

  def users_total = User.count
  def users_new = User.where(created_at: since..).count
  def sellers_active = User.where("listings_count > 0").count
  def listings_live = Listing.visible.count
  def listings_pending = Listing.pending_review.count
  def listings_new = Listing.where(created_at: since..).count
  def orders_count = Order.where(created_at: since..).where.not(status: :cancelled).count
  def gmv_cents = Order.where(paid_at: since..).where.not(status: %i[cancelled refunded]).sum(:total_cents)
  def fees_cents = Order.completed.where(completed_at: since..).sum(:platform_fee_cents)
  def open_disputes = Order.disputed.count
  def open_reports = Report.open.count
  def open_tickets = SupportTicket.open.count
  def newsletter = NewsletterSubscription.active.count
  def overdue_shipments = Order.paid.where(paid_at: ..Setting.get(:seller_ship_days).days.ago).count

  def signups_by_day = daily(User.where(created_at: since..), :created_at)
  def orders_by_day = daily(Order.where(created_at: since..).where.not(status: :cancelled), :created_at)

  def top_categories
    Listing.visible.joins(:category).group(:category_id).order(count_all: :desc).limit(6).count
      .map { |id, count| [ Category.cached_find(id)&.name || id, count ] }
  end

  def oldest_pending = Listing.pending_review.includes(:user).order(:submitted_at).limit(8)

  private

  def daily(scope, column)
    data = scope.group("DATE(#{scope.table_name}.#{column})").count
    (since.to_date..Date.current).map { |day| [ day, data[day].to_i ] }
  end
end
