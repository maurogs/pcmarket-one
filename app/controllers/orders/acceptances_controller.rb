class Orders::AcceptancesController < Orders::BaseController
  def create
    @order.accept!(current_user)
    done(:accepted)
  end
end
