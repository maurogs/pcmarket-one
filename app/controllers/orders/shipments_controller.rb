class Orders::ShipmentsController < Orders::BaseController
  def create
    if params[:tracking_number].blank? && @order.delivery_shipping?
      return redirect_to(order_path(@order), alert: t("orders.errors.tracking_required"))
    end

    if @order.delivery_pickup?
      @order.confirm_delivery!(current_user)
    else
      @order.ship!(current_user, carrier: params[:carrier].to_s.first(40), tracking_number: params[:tracking_number].to_s.strip.first(60))
    end
    done(:shipped)
  end
end
