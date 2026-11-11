# Shared listing grid for search, categories and collections.
module Catalogue
  extend ActiveSupport::Concern

  PER_PAGE = 24

  private

  def render_catalogue(**forced)
    @search = ListingSearch.new(params.permit(*ListingSearch::PERMITTED).to_h.merge(forced))
    @category ||= @search.category
    @filters = @category ? @category.applicable_filters : FilterDefinition.none
    @pagy, @listings = pagy(:offset, @search.results.for_card, limit: PER_PAGE)
    @label_options = FilterDefinition.cached_by_key["product_labels"]
    @tag_options = FilterDefinition.cached_by_key["seller_tags"]
    render "listings/index"
  end
end
