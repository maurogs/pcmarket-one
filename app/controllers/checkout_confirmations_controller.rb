class CheckoutConfirmationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @orders = current_user.purchases.where(checkout_reference: params[:reference].to_s).includes(:seller, :items)
    raise ActiveRecord::RecordNotFound if @orders.empty?
  end
end
