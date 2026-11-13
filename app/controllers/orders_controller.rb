class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @orders = pagy(:offset, current_user.purchases.recent.includes(:seller, items: { listing: { photos_attachments: :blob } }), limit: 20)
  end

  def show
    @order = Order.includes(:events, :review, items: { listing: { photos_attachments: :blob } }).find_by!(number: params[:number])
    authorize!(@order.participant?(current_user) || current_user.staff?)
    @role = @order.seller_id == current_user.id ? :seller : :buyer
  end
end
