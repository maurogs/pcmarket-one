class Orders::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order

  rescue_from Order::InvalidTransition do
    redirect_to order_path(@order), alert: t("orders.errors.invalid_transition")
  end

  private

  def set_order
    @order = Order.find_by!(number: params[:order_number])
    authorize!(@order.participant?(current_user))
  end

  def done(key)
    redirect_to order_path(@order), notice: t("orders.actions.#{key}")
  end
end
