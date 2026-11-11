class CheckoutsController < ApplicationController
  before_action :require_active_user!
  before_action { require_feature!(:checkout_enabled) }
  before_action :prepare

  def show
    redirect_to cart_path, alert: t("checkout.errors.empty") if @groups.empty?
  end

  def create
    address = current_user.addresses.find_by(id: params[:address_id])
    result = Checkout.new(cart: current_cart, buyer: current_user, address: address,
                          delivery_methods: params.fetch(:delivery, {}).permit!.to_h,
                          discount_codes: params.fetch(:discount, {}).permit!.to_h, note: params[:note]).call
    current_cart.items.destroy_all
    gateway = Payments::Gateway.current
    redirect_to gateway.start(result.orders,
                              success_url: checkout_confirmation_url(reference: result.reference),
                              cancel_url: orders_url), allow_other_host: true
  rescue Checkout::Error => e
    flash.now[:alert] = e.message
    render :show, status: :unprocessable_entity
  end

  private

  def prepare
    removed = current_cart.prune!
    flash.now[:alert] = t("carts.show.removed", titles: removed.to_sentence) if removed.any?
    own = current_cart.items.joins(:listing).where(listings: { user_id: current_user.id })
    own.destroy_all
    @groups = current_cart.groups_by_seller
    @addresses = current_user.addresses
    @address = current_user.addresses.new(full_name: current_user.full_name, country_code: current_country.code)
  end
end
