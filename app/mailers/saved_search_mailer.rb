class SavedSearchMailer < ApplicationMailer
  def matches
    @saved_search = params[:saved_search]
    @listings = Listing.where(id: params[:listing_ids]).for_card
    with_locale_for(@saved_search.user) do
      mail to: @saved_search.user.email, subject: t("mailers.saved_search.matches.subject", name: @saved_search.name, count: @listings.size)
    end
  end
end
