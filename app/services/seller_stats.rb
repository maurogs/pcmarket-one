class SellerStats
  PERIODS = { "7d" => 7, "30d" => 30, "90d" => 90, "365d" => 365 }.freeze

  attr_reader :seller, :period

  def initialize(seller, period: nil)
    @seller = seller
    @period = PERIODS.key?(period) ? period : "30d"
  end

  def since = PERIODS[period].days.ago

  def revenue_cents = completed_sales.sum(:total_cents) - completed_sales.sum(:platform_fee_cents)
  def orders_count = seller.sales.where(created_at: since..).where.not(status: :cancelled).count
  def pending_shipments = seller.sales.paid.count
  def open_disputes = seller.sales.disputed.count
  def views = seller.listings.sum(:views_count)
  def favorites = seller.listings.sum(:favorites_count)
  def active_listings = seller.listings.published.count
  def pending_listings = seller.listings.pending_review.count
  def rejected_listings = seller.listings.rejected.count
  def unanswered_offers = Offer.open.where(seller: seller).count

  # Daily revenue series for the chart.
  def revenue_by_day
    completed_sales.group("DATE(orders.completed_at)").sum(:total_cents)
      .then { |data| (since.to_date..Date.current).map { |day| [ day, data[day].to_i ] } }
  end

  def top_listings = seller.listings.published.order(views_count: :desc).limit(5)

  private

  def completed_sales = seller.sales.completed.where(completed_at: since..)
end
