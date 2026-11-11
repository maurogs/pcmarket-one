class Orders::DisputesController < Orders::BaseController
  def create
    reason = params[:reason].to_s.strip
    return redirect_to(order_path(@order), alert: t("orders.errors.reason_required")) if reason.length < 10

    @order.dispute!(current_user, reason.first(2000))
    done(:disputed)
  end
end
