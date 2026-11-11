class HomeController < ApplicationController
  def show
    @page = HomePage.new
    fresh_when etag: [ @page.cache_key, I18n.locale, current_user&.id, cart_items_count ], public: false
  end
end
