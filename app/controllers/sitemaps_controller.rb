class SitemapsController < ApplicationController
  def show
    @listings = Listing.visible.in_enabled_countries.select(:id, :slug, :updated_at).order(updated_at: :desc).limit(45_000)
    @categories = Category.active.select(:slug, :updated_at)
    @stores = User.active.where("listings_count > 0").select(:username, :updated_at).limit(5_000)
    @collections = Collection.active.select(:slug, :updated_at)
    @locales = enabled_locales
    expires_in 1.hour, public: true
  end
end
