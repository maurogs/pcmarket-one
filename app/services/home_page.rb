# Query object for the home page sections. Each section is a small, indexed query.
class HomePage
  SECTION_SIZE = 10

  def cache_key
    [Listing.maximum(:updated_at)&.to_i, Collection.maximum(:updated_at)&.to_i, Setting.maximum(:updated_at)&.to_i]
  end

  def hero_deals = base.on_sale.order(Arel.sql("(original_price_cents - price_cents) DESC")).limit(5)
  def most_watched = base.where(published_at: 30.days.ago..).order(favorites_count: :desc, views_count: :desc).limit(SECTION_SIZE)
  def newest = base.order(published_at: :desc).limit(SECTION_SIZE)
  def on_sale = base.on_sale.order(published_at: :desc).limit(SECTION_SIZE)
  def featured = base.where(featured: true).order(published_at: :desc).limit(SECTION_SIZE)
  def themes = Collection.active.theme.ordered.with_attached_image.limit(6)
  def home_sections = Collection.active.home_section.where(show_on_home: true).ordered
  def recently_sold = Listing.sold.joins(:user).merge(User.active).for_card.order(updated_at: :desc).limit(SECTION_SIZE)
  def recent_reviews = Review.visible.where(rating: 5).where.not(body: [nil, ""]).includes(:seller, :reviewer).recent.limit(3)

  def gpus
    category = Category.find_by(slug: "gpus")
    category ? base.where(category_id: category.descendant_ids).order(published_at: :desc).limit(SECTION_SIZE) : Listing.none
  end

  def section_listings(collection)
    collection.search.results.for_card.limit(SECTION_SIZE)
  end

  private

  def base
    Listing.visible.in_enabled_countries.for_card
  end
end
