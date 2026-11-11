class Orders::DeliveriesController < Orders::BaseController
  def create
    raise Order::NotAllowed unless current_user == @order.buyer

    @order.confirm_delivery!(current_user)
    done(:delivered)
  end
end
