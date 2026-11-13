class SavedSearchDigestJob < ApplicationJob
  queue_as :low

  def perform
    return unless Setting.enabled?(:saved_search_alerts_enabled)

    SavedSearch.notifiable.daily.includes(:user).find_each do |saved_search|
      since = saved_search.last_notified_at || 1.day.ago
      ids = saved_search.search.results.where(published_at: since..).where.not(user_id: saved_search.user_id).limit(12).pluck(:id)
      next if ids.empty?

      SavedSearchMailer.with(saved_search: saved_search, listing_ids: ids).matches.deliver_later if saved_search.user.notify_by_email?(:saved_searches)
      saved_search.update_column(:last_notified_at, Time.current)
    end
  end
end
