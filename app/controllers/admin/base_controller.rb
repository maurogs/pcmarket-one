class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_staff!

  PER_PAGE = 30

  private

  def paginate(scope, limit: PER_PAGE)
    pagy(:offset, scope, limit: limit)
  end

  # Sorting restricted to an allow-list of columns.
  def sorted(scope, allowed, default)
    column = allowed.include?(params[:sort]) ? params[:sort] : default
    direction = params[:dir] == "asc" ? :asc : :desc
    scope.reorder(column => direction, id: direction)
  end
end
