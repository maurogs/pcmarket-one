class CategoriesController < ApplicationController
  include Catalogue

  def show
    @category = Category.active.find_by!(slug: params[:id])
    render_catalogue(category: @category.slug)
  end
end
