module Api
  module V1
    class OrdersController < BaseController
      before_action :authenticate!

      def index
        scope = params[:role] == "seller" ? current_user.sales : current_user.purchases
        orders = paginate(scope.recent.includes(:items))
        render json: { data: orders.map { |o| OrderSerializer.call(o) }, meta: @pagination }
      end

      def show
        order = Order.includes(:items, :events).find_by!(number: params[:id])
        authorize!(order.participant?(current_user))
        render json: { data: OrderSerializer.call(order, events: true) }
      end
    end
  end
end
