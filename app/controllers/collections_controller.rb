class CollectionsController < ApplicationController
  include Catalogue

  def show
    @collection = Collection.active.find_by!(slug: params[:id])
    render_catalogue(**@collection.query.symbolize_keys)
  end
end
