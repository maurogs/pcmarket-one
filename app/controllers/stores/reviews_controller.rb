class Stores::ReviewsController < ApplicationController
  def index
    @store = User.find_by!("lower(username) = ?", params[:store_id].to_s.downcase)
    order = params[:order] == "oldest" ? :asc : :desc
    @pagy, @reviews = pagy(:offset, @store.reviews_received.includes(:reviewer, order: :items).order(created_at: order), limit: 10)
  end
end
