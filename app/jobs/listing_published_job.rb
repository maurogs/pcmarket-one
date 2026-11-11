class ListingPublishedJob < ApplicationJob
  queue_as :default

  def perform(listing_id)
    listing = Listing.find_by(id: listing_id)
    return unless listing&.published?

    path = AppRoutes.helpers.listing_path(listing)
    listing.user.followers.find_each do |follower|
      Notification.deliver(follower, :followed_seller_listing, path: path, seller: listing.user.display_name, title: listing.title)
    end
    notify_saved_searches(listing, path)
  end

  private

  def notify_saved_searches(listing, path)
    return unless Setting.enabled?(:saved_search_alerts_enabled)

    SavedSearch.notifiable.instant.where.not(user_id: listing.user_id).includes(:user).find_each do |saved_search|
      next unless saved_search.matches?(listing)

      Notification.deliver(saved_search.user, :saved_search_match, path: path, name: saved_search.name, title: listing.title)
      if saved_search.user.notify_by_email?(:saved_searches)
        SavedSearchMailer.with(saved_search: saved_search, listing_ids: [listing.id]).matches.deliver_later
      end
      saved_search.update_column(:last_notified_at, Time.current)
    end
  end
end
