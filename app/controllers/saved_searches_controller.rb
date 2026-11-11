class SavedSearchesController < ApplicationController
  before_action :authenticate_user!
  before_action { require_feature!(:saved_search_alerts_enabled) }

  def index
    @saved_searches = current_user.saved_searches.order(created_at: :desc)
  end

  def create
    query = ListingSearch.new(params.fetch(:query, {}).permit(*ListingSearch::PERMITTED).to_h).to_query_hash
    saved_search = current_user.saved_searches.new(name: params[:name].presence || default_name(query), query: query,
                                                   frequency: params[:frequency].presence || :instant)
    if saved_search.save
      redirect_back fallback_location: saved_searches_path, notice: t(".success")
    else
      redirect_back fallback_location: saved_searches_path, alert: saved_search.errors.full_messages.to_sentence
    end
  end

  def update
    saved_search = current_user.saved_searches.find(params[:id])
    saved_search.update(params.require(:saved_search).permit(:name, :notify, :frequency))
    redirect_to saved_searches_path, notice: t(".success")
  end

  def destroy
    current_user.saved_searches.find(params[:id]).destroy
    redirect_to saved_searches_path, notice: t(".success"), status: :see_other
  end

  private

  def default_name(query)
    [ query[:q], Category.find_by(slug: query[:category])&.name ].compact_blank.join(" · ").presence || t("saved_searches.default_name")
  end
end
