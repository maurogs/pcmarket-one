class Admin::CollectionsController < Admin::BaseController
  include AdminTranslations
  before_action :set_collection, only: %i[edit update destroy]

  def index
    @collections = Collection.ordered.with_attached_image
  end

  def new
    @collection = Collection.new(position: Collection.maximum(:position).to_i + 1)
  end

  def create
    @collection = Collection.new(collection_params)
    save_and_respond(:new)
  end

  def edit; end

  def update
    @collection.assign_attributes(collection_params)
    save_and_respond(:edit)
  end

  def destroy
    @collection.destroy
    redirect_to admin_collections_path, notice: t("admin.flash.destroyed"), status: :see_other
  end

  private

  def set_collection
    @collection = Collection.find_by!(slug: params[:id])
  end

  def save_and_respond(template)
    if @collection.save
      audit!("collection.saved", @collection)
      redirect_to admin_collections_path, notice: t("admin.flash.updated")
    else
      render template, status: :unprocessable_entity
    end
  end

  # The query is edited as a catalogue URL query string (e.g. "category=gaming-pcs&tags[]=minimalist").
  def collection_params
    permitted = params.require(:collection).permit(:slug, :kind, :accent_color, :active, :show_on_home, :position, :image, :query_string,
                                                   *translated_attributes(:title, :subtitle))
    if permitted.key?(:query_string)
      raw = Rack::Utils.parse_nested_query(permitted.delete(:query_string).to_s.delete_prefix("?"))
      permitted[:query] = ListingSearch.new(raw).to_query_hash.merge(raw.slice("sort")).deep_stringify_keys
    end
    permitted
  end
end
